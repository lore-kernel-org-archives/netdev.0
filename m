From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 21:23:17 +1000
Message-ID: <E1G63xV-0004LN-00@gondolin.me.apana.org.au>
References: <BAY103-F2CBF2C86BB9EF11201CBEB2580@phx.gbl>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8974 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751308AbWG0LXU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 07:23:20 -0400
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-F2CBF2C86BB9EF11201CBEB2580@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> 
> 172.16.0.0/23 dev eth2  proto kernel  scope link  src 172.16.1.1
> 10.180.0.0/16 via 172.16.1.253 dev eth2
> 10.0.0.0/8 via pub_ip dev eth0
> 127.0.0.0/8 dev lo  scope link
> 
> I have noticed that packets for 10.180.0.0/16 network
> are eaten by the ipsec tunnel because the policy allow
> them. Is there a way to deliver packets for 10.180.0.0
> network to the 172.16.1.253 router (because the route
> to 10.180.0.0 is more specific than 10.0.0.0/8)?

You need an IPsec pass action.  With Openswan you can do it with
something like

conn pass
	left=%defaultroute
	# This should be the leftsubnet of your 10.0.0.0/8 connection.
	leftsubnet=0.0.0.0/0
	# This field doesn't really matter.
	right=172.16.1.253
	rightsubnet=10.180.0.0/16
        type=passthrough
        authby=never
        auto=route

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
