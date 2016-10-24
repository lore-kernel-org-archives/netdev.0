From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Mon, 24 Oct 2016 08:38:45 -0400
Message-ID: <369b7b2c-d1fb-5dd2-30b9-4f54400aa770@mojatatu.com>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
 <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
 <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
 <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
 <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
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
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33280 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935973AbcJXMit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 08:38:49 -0400
Received: by mail-yw0-f196.google.com with SMTP id w3so9112380ywg.0
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 05:38:49 -0700 (PDT)
In-Reply-To: <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-24 02:30 AM, Xin Long wrote:

> in case [1], user can't see the ENOMEM, ENOMEM is more like
> a internal err.
>

Still not clear. Are you saying, say an old kernel like 3.11 would
not return the user ENOMEN for the use case[1] you fixed? I am not
talking post your fix.

> in case [2], user will got the ENOMEM, they should resend this msg,
> It's the the general case mentioned-above
>

I am trying to see if we can avoid backporting this fix to 3.11.
In [1], is ENOMEM propagated to user space (dont talk about your
fix, I mean pre-your-fix).


> here sctp's behavior is actually same with tcp's, in tcp, tcp_transmit_skb
> also may fail to alloc skb, but it doesn't return any err to user, just like
> sctp_packet_transmit. That's why I don't think we should change something
> in manpage, as here sctp is consistent with tcp now.
>
> make sense ?

No ;-> The manpage is bad. Go look at it. In the case of ENOBUFS or
EMSGSIZE it is clear what needs to be done.
If the answer is _on ENOMEM_ user must resend then thats what we need
to say.

cheers,
jamal
