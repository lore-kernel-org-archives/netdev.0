From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: reduce cpu usage under tcp memory
 pressure when SO_SNDBUF is set
Date: Mon, 10 Aug 2015 14:26:30 -0700
Message-ID: <1439241990.1084.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150807183136.D0DF92026@prod-mail-relay10.akamai.com>
	 <1439218022.1084.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55C8DF6B.9080509@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35025 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932726AbbHJV0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:26:32 -0400
Received: by pacgr6 with SMTP id gr6so34769110pac.2
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 14:26:31 -0700 (PDT)
In-Reply-To: <55C8DF6B.9080509@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-10 at 13:29 -0400, Jason Baron wrote:
> > +
> > 
> > 
> > 
> > 
> 
> thanks. better?
> 
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -798,8 +798,10 @@ static inline int sk_stream_min_wspace(const struct
> sock *sk)
> 
>  static inline int sk_stream_wspace(const struct sock *sk)
>  {
> -       if (sk->sk_effective_sndbuf)
> -               return sk->sk_effective_sndbuf - sk->sk_wmem_queued;
> +       int effective_sndbuf = sk->sk_effective_sndbuf;
> +
> +       if (effective_sndbuf)
> +               return effective_sndbuf - sk->sk_wmem_queued;
> 
>         return sk->sk_sndbuf - sk->sk_wmem_queued;
>  }
> 
> 

You need to use instead :

int effective_sndbuf = READ_ONCE(sk->sk_effective_sndbuf);
