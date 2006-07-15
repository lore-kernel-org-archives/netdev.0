From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2  2.6.18-rc1-mm2   1/3]  net:  UDP-Lite generic support
Date: Sat, 15 Jul 2006 23:33:16 +1000
Message-ID: <E1G1kGi-000549-00@gondolin.me.apana.org.au>
References: <200607141719.02766@strip-the-willow>
Cc: akpm@osdl.org, davem@davemloft.net, yoshfuji@linux-ipv6.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@coreworks.de,
	pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8708 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1946038AbWGONeR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 09:34:17 -0400
To: gerrit@erg.abdn.ac.uk (Gerrit Renker)
In-Reply-To: <200607141719.02766@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> diff -Nurp  a/net/core/sock.c b/net/core/sock.c
> --- a/net/core/sock.c   2006-07-06 09:08:24.000000000 +0100
> +++ b/net/core/sock.c   2006-07-14 10:17:50.000000000 +0100
> @@ -479,7 +479,12 @@ set_rcvbuf:
>                        break;
> 
>                case SO_NO_CHECK:
> -                       sk->sk_no_check = valbool;
> +                       /* UDP-Lite (RFC 3828) mandates checksumming,
> +                        * hence user must not enable this option.   */
> +                       if (sk->sk_protocol == IPPROTO_UDPLITE)
> +                               ret = -EOPNOTSUPP;
> +                       else
> +                           sk->sk_no_check = valbool;

Please don't add protocol-specific stuff to generic functions.  In this
case why don't you just ignore sk_no_check for UDPLITE as we do for TCP?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
