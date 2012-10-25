From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Thu, 25 Oct 2012 16:15:38 -0700
Message-ID: <CAGK4HS8J2v=2SxmpwXR9vkyXJ9ibhMrPdMgUFxjTyXGt3g7vxA@mail.gmail.com>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
	<1351204948.6537.263.camel@edumazet-glaptop>
	<CAK3+h2zLGGA2w38mRwpf5Ww+d8ZdtESp1zix82OZODG7o=Rsbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:50283 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab2JYXPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 19:15:38 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so2159846oag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 16:15:38 -0700 (PDT)
In-Reply-To: <CAK3+h2zLGGA2w38mRwpf5Ww+d8ZdtESp1zix82OZODG7o=Rsbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> thanks for the reply, I did a quick look at the code, as a quick dirty
> hack, can I change the
>
>  699 /* Set up TCP options for SYN-ACKs. */
>  700 static unsigned int tcp_synack_options(struct sock *sk,
>  701                                    struct request_sock *req,
>  702                                    unsigned int mss, struct sk_buff *skb,
>  703                                    struct tcp_out_options *opts,
>  704                                    struct tcp_md5sig_key **md5,
>  705                                    struct tcp_extend_values *xvp)
>  706 {
>
> ..................
>  730         /* We always send an MSS option. */
>  731         opts->mss = mss; <---------here set opts->mss = 0 ?
>
> would that work?


tcp_make_synack() calls tcp_options_write() has this:

        if (unlikely(opts->mss)) {
                *ptr++ = htonl((TCPOPT_MSS << 24) |
                               (TCPOLEN_MSS << 16) |
                               opts->mss);
        }

It will not add the option if opts->mss is zero, so this should work too.

Vijay
