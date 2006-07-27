From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel policy vs routing table
Date: Fri, 28 Jul 2006 08:07:27 +1000
Message-ID: <20060727220727.GA21619@gondor.apana.org.au>
References: <E1G63xV-0004LN-00@gondolin.me.apana.org.au> <BAY103-F281E5B6AC611062170572AB2580@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22029 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751363AbWG0WHa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 18:07:30 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F281E5B6AC611062170572AB2580@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2006 at 04:06:44PM +0200, Marco Berizzi wrote:
> 
> conn pass
> 	left=172.16.1.1
> 	leftsubnet=172.16.0.0/23
> 	right=172.16.1.253
> 	rightsubnet=10.180.0./16
> 	type=passthrough
> 	authby=never
> 	auto=route
> 
> After running 'ipsec auto --add pass && ipsec auto
> --route pass' openswan has eaten my static route
> inserted by hand:
> route add -net 10.180.0.0/16 gw 172.16.1.253
> Here is 'ip r s' output after 'ipsec auto --route
> pass':
> 172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
> 10.180.0.0/16 dev eth2  scope link

Oh yeah, forgot about that :)

You can set the gateway using rightnexthop=172.16.1.253.

> All if fine now. It isn't even needed anymore to
> insert the static route now, as it is placed by
> openswan. My question is how linux understand that
> it should send packets for 10.180.0.0/24 to the
> 172.16.1.253 router.

It doesn't really.  However your router might be proxy arping.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
