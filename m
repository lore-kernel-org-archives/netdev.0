From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec PMTUD problem
Date: Tue, 3 Apr 2007 19:55:10 +1000
Message-ID: <20070403095510.GA7754@gondor.apana.org.au>
References: <46110ED1.9070209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1269 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965028AbXDCJzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 05:55:19 -0400
Content-Disposition: inline
In-Reply-To: <46110ED1.9070209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick:

On Mon, Apr 02, 2007 at 04:10:25PM +0200, Patrick McHardy wrote:
> I noticed a problem with PMTUD between two IPsec tunnel endpoints.
> When sending a packet larger than the PMTU with IP_DF from one
> tunnel endpoint to the other, xfrm4_output sends an ICMP frag.
> required with the IPsec MTU. Since the addresses match the tunnel
> endpoints, this updates the MTU for the XFRM route with the value
> that was calculated for the entire bundle, which in turn causes
> a decrease for the bundle, resulting in further ICMP frag. required
> messages until the minimum is reached.

I presume you're using the same pair of addresses inside and
outside the tunnel? If so the problem is that the kernel doesn't
distinguish between internal ICMP errors and external ones.
So when an MTU update occurs for the internal pair the external
pair is also affected.

We'd need some field in the routing cache to distinguish the
two pairs.

Of course the easy work-around is to use distinct addresses
within IPsec tunnels.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
