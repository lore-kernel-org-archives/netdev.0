From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: more driver shutdown WoL regression.
Date: Thu, 10 Nov 2011 12:11:06 +0800
Message-ID: <DCB55CA56A5546B4B7350912D30EC679@realtek.com.tw>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com> <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw> <20111109222556.GA8226@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'Stefan Becker' <chemobejk@gmail.com>,
	'David Miller' <davem@davemloft.net>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:44187 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934189Ab1KJELV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 23:11:21 -0500
In-Reply-To: <20111109222556.GA8226@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> 
> I tested in the following order
> RTL_GIGA_MAC_VER_26 (ko)
> RTL_GIGA_MAC_VER_25 (ko)
> RTL_GIGA_MAC_VER_12 (ko)
> RTL_GIGA_MAC_VER_34 (ok)
> RTL_GIGA_MAC_VER_33 (ok)
> RTL_GIGA_MAC_VER_35 (ok)
> RTL_GIGA_MAC_VER_09 (ko)
> RTL_GIGA_MAC_VER_09 (ko)
> RTL_GIGA_MAC_VER_30 (ok)
> RTL_GIGA_MAC_VER_30 (ok)
> RTL_GIGA_MAC_VER_06 (ok)
> 
> Each test:
> - proceeded from a fresh boot
> - dmesg | grep XID; ip link show
>   -> check MAC address (devices were set through udev long beforehand)
> - ip link set dev xyz up
> - ethtool xyz
>   -> check link status up
> - ethtool peer
>   -> check link status up, 1000 Mbps or 100 Mbps
> - ethtool -s xyz wol g; ethtool xyz
> - telinit 0
> - ethtool peer
>   -> check link status up, 10 Mbps
> - ether-wake -i peer mac_addr (triple check the mac address here)
> 
> (stop, power off, unplug, plug, power on, repeat)
> 

I find that the magic packet which I send is the broadcast packet, and the one
which you send is the unicast packet. That is, you could wake up the system by
using broadcast magic packet for the previous chips without the patch. However,
if you prefer to unicast magic packet, this patch is necessary. Besides, no
matter broadcast or unicast magic packet, the patch is necessary for 8105,
8168e, and later chips. Further, it may be dangerous to enable both rx_enable
(ChipCmd bit 3) and RxConfig for 8168b for WOL, because the hw would try to
write the rx buffer.
 
Best Regards,
Hayes
