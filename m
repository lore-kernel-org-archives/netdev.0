From: Xin Long <lucien.xin@gmail.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Mon, 24 Oct 2016 14:30:07 +0800
Message-ID: <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
 <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com> <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
 <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36217 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754938AbcJXGaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 02:30:08 -0400
In-Reply-To: <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1]
>> This patch doesn't ignore all the ENOMEN cases, only after msg is
>> enqueued in out queue/send queue, in the lower layer, when alloc
>> new skb and copy data from old skb, if it fails to alloc new skb, sctp
>> will ignore this ENOMEM, as this msg will be taken care by retransmit
>> mechanism, it's reasonable and also safe, user can't feel that.
>>
>
> Yes, that part i got.
>

[2]
>> But for the cases before enqueue, like in sctp_sendmsg,
>> sctp_datamsg_from_user may return ENOMEM, this err will return
>> back to user, and can't be ignored.
>>
>
> The hard part is distinguishing between the above case and real
> failure.
> I am assuming in the case above user is _not_ required to send
> again. But in the general case they are required to send again.
> Correct?
in case [1], user can't see the ENOMEM, ENOMEM is more like
a internal err.

in case [2], user will got the ENOMEM, they should resend this msg,
It's the the general case mentioned-above

>
>> So I don't really think we should change something in manpage, what
>> do you think ? maybe a little explanation there is also nice, :)
>
>
> Yes, that would help. In particular it should be clear what user space
> is expected to do. While this is about sctp - I am assuming equivalent
> behavior for all callers of sendxxx() regardless of protocol.
here sctp's behavior is actually same with tcp's, in tcp, tcp_transmit_skb
also may fail to alloc skb, but it doesn't return any err to user, just like
sctp_packet_transmit. That's why I don't think we should change something
in manpage, as here sctp is consistent with tcp now.

make sense ?
