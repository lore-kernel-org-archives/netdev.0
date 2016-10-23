From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Sun, 23 Oct 2016 15:52:08 -0400
Message-ID: <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
 <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
 <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34679 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754882AbcJWTwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 15:52:11 -0400
Received: by mail-yw0-f195.google.com with SMTP id u124so5381864ywg.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 12:52:10 -0700 (PDT)
In-Reply-To: <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-23 02:20 PM, Xin Long wrote:

> This patch doesn't ignore all the ENOMEN cases, only after msg is
> enqueued in out queue/send queue, in the lower layer, when alloc
> new skb and copy data from old skb, if it fails to alloc new skb, sctp
> will ignore this ENOMEM, as this msg will be taken care by retransmit
> mechanism, it's reasonable and also safe, user can't feel that.
>

Yes, that part i got.

> But for the cases before enqueue, like in sctp_sendmsg,
> sctp_datamsg_from_user may return ENOMEM, this err will return
> back to user, and can't be ignored.
>

The hard part is distinguishing between the above case and real
failure.
I am assuming in the case above user is _not_ required to send
again. But in the general case they are required to send again.
Correct?

> So I don't really think we should change something in manpage, what
> do you think ? maybe a little explanation there is also nice, :)

Yes, that would help. In particular it should be clear what user space
is expected to do. While this is about sctp - I am assuming equivalent
behavior for all callers of sendxxx() regardless of protocol.

cheers,
jamal
