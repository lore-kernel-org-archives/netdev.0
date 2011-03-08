From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-2.6] r6040: fix multicast operations
Date: Tue, 08 Mar 2011 14:22:05 -0800 (PST)
Message-ID: <20110308.142205.71118599.davem@davemloft.net>
References: <201103071109.40853.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754686Ab1CHWV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 17:21:28 -0500
In-Reply-To: <201103071109.40853.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 7 Mar 2011 11:09:40 +0100

> From: Shawn Lin <shawn@dmp.com.tw>
> 
> The original code does not work well when the number of mulitcast
> address to handle is greater than MCAST_MAX. It only enable promiscous
> mode instead of multicast hash table mode, so the hash table function
> will not be activated and all multicast frames will be recieved in this
> condition.
> 
> This patch fixes the following issues with the r6040 NIC operating in
> multicast:
> 
> 1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC
> hash table registers to make it process multicast traffic.
> 
> 2) When the number of multicast address to handle is smaller than
> MCAST_MAX, we should use the NIC multicast registers MID1_{L,M,H}.
> 
> 3) The hashing of the address was not correct, due to an invalid
> substraction (15 - (crc & 0x0f)) instead of (crc & 0x0f) and an
> incorrect crc algorithm (ether_crc_le) instead of (ether_crc).
> 
> 4) If necessary, we should set HASH_EN flag in MCR0 to enable multicast
> hash table function.
> 
> Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
> Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Applied.
