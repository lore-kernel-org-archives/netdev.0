From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 21:21:53 +1000
Message-ID: <20060711112153.GB11175@gondor.apana.org.au>
References: <BAY103-F209936DACD91675B1D73DFB2680@phx.gbl> <BAY103-F36F59C0E4B463B590831A5B2680@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:64529 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751017AbWGKLV4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 07:21:56 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F36F59C0E4B463B590831A5B2680@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2006 at 11:31:33AM +0200, Marco Berizzi wrote:
> 
> Me again. After a while here is:
> 
> root@Mimosa:/tmp# ping 10.49.59.23
> PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
> 
> --- 10.49.59.23 ping statistics ---
> 4 packets transmitted, 0 received, 100% packet loss, time 3010ms

Please check using ip -s x p to make sure that the packet is hitting
the right policy.  Unfortunately we don't update the byte/packet counters
so you'll have to look at the `use' time stamp.

If it's passing through IPsec, then you should trace through your
iptables rules using the LOG target to see if it's hitting them.

We need to know if it's being dropped before, in, or after netfilter.

Please also do ip r g 10.49.59.23 to make sure that it says something
sane.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
