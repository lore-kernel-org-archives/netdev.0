From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Wed, 13 Aug 2008 11:09:35 +1000
Message-ID: <20080813010935.GA29815@gondor.apana.org.au>
References: <20080812005839.GC18547@gondor.apana.org.au> <200808121817.19662.netdev@axxeo.de> <20080812233753.GA29155@gondor.apana.org.au> <20080812.175532.137434164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56544 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752742AbYHMBJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:09:47 -0400
Content-Disposition: inline
In-Reply-To: <20080812.175532.137434164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 05:55:32PM -0700, David Miller wrote:
> 
> The whole point of the auxdata thing was that if your tool is smart
> you can get the notification that the checksum is going to be HW
> computed and therefore keep capturing at a very low cost.
> 
> But for a stupid AF_PACKET user, like dhclient currently is, there is
> no harm in COW'ing the packet header area and calculating the checksum
> for them in this case.

Right I'm not against adding this to AF_PACKET.

It's just that the virtualisation problem that started all this
is just as easily resolved by user-space.  In fact the dhcp-client
code in RHEL/Fedora has been patched to do exactly this a long time
ago.

> I kind of hope that libpcap/tcpdump has been taught about auxdata
> by now, has it? :-/

Unfortunately no.  This also means that if we do do this in AF_PACKET,
then running a packet dump on a fast outbound interface may become more
expensive.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
