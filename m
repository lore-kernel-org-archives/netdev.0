From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Tue, 15 Jan 2013 05:20:47 +0900
Message-ID: <50F4689F.9030806@linux-ipv6.org>
References: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40050 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757243Ab3ANUUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:20:50 -0500
In-Reply-To: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
>  static inline struct sock *inet_lookup_listener(struct net *net,
>  		struct inet_hashinfo *hashinfo,
> +		__be32 saddr, __be16 sport,
>  		__be32 daddr, __be16 dport, int dif)
>  {
> -	return __inet_lookup_listener(net, hashinfo, daddr, ntohs(dport), dif);
> +	return __inet_lookup_listener(net, hashinfo, saddr, sport,
> +	    daddr, ntohs(dport), dif);
>  }
>  
>  /* Socket demux engine toys. */
> @@ -358,7 +364,8 @@ static inline struct sock *__inet_lookup(struct net *net,
>  	struct sock *sk = __inet_lookup_established(net, hashinfo,
>  				saddr, sport, daddr, hnum, dif);
>  
> -	return sk ? : __inet_lookup_listener(net, hashinfo, daddr, hnum, dif);
> +	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
> +	    daddr, hnum, dif);
>  }
>  

Please fix indent.

--yoshfuji
