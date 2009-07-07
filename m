From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Tue, 7 Jul 2009 09:58:50 +0800
Message-ID: <20090707015850.GA27305@gondor.apana.org.au>
References: <20090630140835.GA20811@gondor.apana.org.au> <20090706.183029.82831402.davem@davemloft.net> <20090707014008.GA27100@gondor.apana.org.au> <20090706.185411.136676235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christophe@saout.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58480 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753635AbZGGB6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:58:51 -0400
Content-Disposition: inline
In-Reply-To: <20090706.185411.136676235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 06:54:11PM -0700, David Miller wrote:
> 
> Hmmm, aren't we talking about packets which were protected by either a
> hash, strong encryption, or both at some point?

Only if there is no inner NAT, i.e., only if this patch isn't
needed.  Otherwise

Source  ---  GW1  ----  GW2  ---  Dest

the path between Source and GW1, will be unprotected if transport
mode is used between GW1 and GW2.  The only bit protected by IPsec's
hash is between GW1 and GW2.

When the traffic comes back, then the bit between Dest and GW2 will
be unprotected.  This is why the only safe way to use this would be
if your traffic is one-way and you only had inner NAT at the other
end.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
