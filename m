From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: when having to acquire an SA, ipsec drops the packet
Date: Mon, 5 Feb 2007 14:49:17 -0600
Message-ID: <000701c74967$1ad9a9c0$cc0a010a@tcssec.com>
References: <20070204.205315.10325007.davem@davemloft.net>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <latten@austin.ibm.com>, <netdev@vger.kernel.org>,
	<paul.moore@hp.com>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	<herbert@gondor.apana.org.au>
To: "'David Miller'" <davem@davemloft.net>, <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:36580 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbXBEUv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 15:51:57 -0500
In-Reply-To: <20070204.205315.10325007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Something like this (untested) on the ipv4 side, for example:
> 
> diff --git a/include/net/route.h b/include/net/route.h
> index 486e37a..a8af632 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -146,7 +146,8 @@ static inline char rt_tos2priority(u8 tos)
>  
>  static inline int ip_route_connect(struct rtable **rp, __be32 dst,
>  				   __be32 src, u32 tos, int 
> oif, u8 protocol,
> -				   __be16 sport, __be16 dport, 
> struct sock *sk)
> +				   __be16 sport, __be16 dport, 
> struct sock *sk,
> +				   int flags)
>  {
>  	struct flowi fl = { .oif = oif,
>  			    .nl_u = { .ip4_u = { .daddr = dst,
> @@ -168,7 +169,7 @@ static inline int ip_route_connect(struct 
> rtable **rp, __be32 dst,
>  		*rp = NULL;
>  	}
>  	security_sk_classify_flow(sk, &fl);
> -	return ip_route_output_flow(rp, &fl, sk, 0);
> +	return ip_route_output_flow(rp, &fl, sk, 1);

I guess you meant to pass the new flags param to ip_route_output_flow here?

>  }
> 
