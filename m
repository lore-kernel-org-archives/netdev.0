From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
 in transport mode
Date: Mon, 06 Jul 2009 19:02:35 -0700 (PDT)
Message-ID: <20090706.190235.248640426.davem@davemloft.net>
References: <20090707014008.GA27100@gondor.apana.org.au>
	<20090706.185411.136676235.davem@davemloft.net>
	<20090707015850.GA27305@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe@saout.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754379AbZGGCC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 22:02:28 -0400
In-Reply-To: <20090707015850.GA27305@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Jul 2009 09:58:50 +0800

> On Mon, Jul 06, 2009 at 06:54:11PM -0700, David Miller wrote:
>> 
>> Hmmm, aren't we talking about packets which were protected by either a
>> hash, strong encryption, or both at some point?
> 
> Only if there is no inner NAT, i.e., only if this patch isn't
> needed.  Otherwise
> 
> Source  ---  GW1  ----  GW2  ---  Dest
> 
> the path between Source and GW1, will be unprotected if transport
> mode is used between GW1 and GW2.  The only bit protected by IPsec's
> hash is between GW1 and GW2.
> 
> When the traffic comes back, then the bit between Dest and GW2 will
> be unprotected.  This is why the only safe way to use this would be
> if your traffic is one-way and you only had inner NAT at the other
> end.

I see.  So people are using transport IPSEC + NAT as a kind of
specialized tunnel.

Indeed, there is no way to handle checksums sanely.  The whole
end-to-end protection of the checksum would be entirely subverted
if we fixed it up.
