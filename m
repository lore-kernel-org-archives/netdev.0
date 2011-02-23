From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/2 net-next-2.6] r6040: fix multicast operations
Date: Wed, 23 Feb 2011 23:32:40 +0100
Message-ID: <201102232332.40712.florian@openwrt.org>
References: <201102231532.34849.florian@openwrt.org> <20110223.142254.59671988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58059 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab1BWWcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:32:46 -0500
Received: by bwz15 with SMTP id 15so534502bwz.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 14:32:45 -0800 (PST)
In-Reply-To: <20110223.142254.59671988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Wednesday 23 February 2011 23:22:54 David Miller wrote:
> From: Florian Fainelli <florian@openwrt.org>
> Date: Wed, 23 Feb 2011 15:32:34 +0100
> 
> > From: Shawn Lin <shawn@dmp.com.tw>
> > 
> > The original code does not work well when the number of mulitcast
> > address to handle is greater than MCAST_MAX. It only enable promiscous
> > mode instead of multicast hash table mode, so the hash table function
> > will not be activated and all multicast frames will be recieved in this
> > condition.
> > 
> > This patch fixes the following issues with the r6040 NIC operating in
> > multicast:
> > 
> > 1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC
> > hash table registers to make it process multicast traffic.
> > 
> > 2) When the number of multicast address to handle is smaller than
> > MCAST_MAX, we should use the NIC multicast registers MID1_{L,M,H}.
> > 
> > 3) The hashing of the address was not correct, due to an invalid
> > substraction (15 - (crc & 0x0f)) instead of (crc & 0x0f) and an
> > incorrect crc algorithm (ether_crc_le) instead of (ether_crc).
> > 
> > 4) If necessary, we should set HASH_EN flag in MCR0 to enable multicast
> > hash table function.
> > 
> > CC: stable@kernel.org
> 
> If it's not appropriate for net-2.6, it's not appropriate for -stable
> either.
> 
> I'm applying this to net-next-2.6, as you requested, and removing the
> stable CC: tag from the commit message.

It is appropriate for kernel versions including e1d44477 (net: convert 
multiple drivers to use netdev_for_each_mc_addr). The patch was generated from 
a net-next-2.6 tree, thus the mention in the subject, which was certainly 
misleading, sorry about that.

I will submit a patch for the "older" stable kernel releases prior to that 
commit.
--
Florian
