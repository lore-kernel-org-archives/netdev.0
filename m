From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 02:20:06 -0400 (EDT)
Message-ID: <20140411.022006.1718259701974368498.davem@davemloft.net>
References: <20140410.205128.1312451576920196881.davem@davemloft.net>
	<1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140411054847.GE30855@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ezequiel.garcia@free-electrons.com,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaDKGUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 02:20:11 -0400
In-Reply-To: <20140411054847.GE30855@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 11 Apr 2014 07:48:47 +0200

> I also tried to find how to do this for mv643xx_eth a few years ago
> based on other drivers (eg: tilegx) and failed to find anything
> common. At this level, we're really playing with the NIC's descriptors,
> and many of them have different capabilities (eg: HW checksums for all
> frames, VLAN or none, etc...). I don't really see how this could be
> factorized, and since many NICs do support TSO, I'm not convinced by
> the effort.

I wanted to hook this into the NIU driver as well, which also lacks
TSO support.

The descriptor and checksum part is chip specific, but the segmentation
of the buffer segments, calculating the number of necessary descriptors,
etc. absolutely is not.

Please work on finding a suitable abstraction, it's possible.
