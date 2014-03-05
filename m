From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 04 Mar 2014 19:23:09 -0500 (EST)
Message-ID: <20140304.192309.337489223683931299.davem@davemloft.net>
References: <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
	<20140304.172025.2034977449200344617.davem@davemloft.net>
	<a23fcc368f1421286c1115c2365942ce.squirrel@webmail.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbaCEAXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:23:11 -0500
In-Reply-To: <a23fcc368f1421286c1115c2365942ce.squirrel@webmail.itwm.fhg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Date: Tue, 4 Mar 2014 23:49:33 +0100

> I didn't mean the runtime cost of any conversion that might happen, I was
> thinking about how much these conversions would affect the code that uses
> these header structs. While for the u16/u32 fields this might be not much,
> it will be more for the hardware address fields since these are stored as
> the little endian encoding of u64 field you get when reading the u8[8] as
> a __be64. If I understand you correctly, these fields would also have to
> be in network byte order in the header struct, introducing copy-and-swaps
> in every upper layer that uses those addresses and making address matching
> harder since memcmp won't work anymore.

SUre it would, store the addresses in your internal data structures
as a __be64 too.  That's what IPV4/IPV6 do, we store addresses and
ports in the socket in network byte order.  Comparisons just work.
