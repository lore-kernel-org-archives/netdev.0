From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Fix some corner cases in
 dev_can_checksum()
Date: Wed, 27 Oct 2010 11:00:54 -0700 (PDT)
Message-ID: <20101027.110054.59696544.davem@davemloft.net>
References: <1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
	<AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
	<1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978Ab0J0SAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:00:31 -0400
In-Reply-To: <1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 22 Oct 2010 15:12:19 +0100

> dev_can_checksum() incorrectly returns true in these cases:
> 
> 1. The skb has both out-of-band and in-band VLAN tags and the device
>    supports checksum offload for the encapsulated protocol but only with
>    one layer of encapsulation.
> 2. The skb has a VLAN tag and the device supports generic checksumming
>    but not in conjunction with VLAN encapsulation.
> 
> Rearrange the VLAN tag checks to avoid these.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks for fixing this Ben.

We really do need to figure out how to handle all of the various
"super vlan" encapsulation schemes (Cisco's RFC5517, 802.1ad,
802.1ah), and their offloads.

In fact, 802.1ad and 802.1ah use completely different framing than
the current VLAN bits.
