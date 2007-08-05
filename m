From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug in realtek 8169 ethernet driver
Date: Sun, 5 Aug 2007 23:35:58 +0200
Message-ID: <20070805213557.GA21500@electric-eye.fr.zoreil.com>
References: <20070805155915.GM2761@avontuur.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bram <bram@linux.kernel.as.avontuur.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58403 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbXHEVjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 17:39:16 -0400
Content-Disposition: inline
In-Reply-To: <20070805155915.GM2761@avontuur.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bram <bram@linux.kernel.as.avontuur.org> :
[...]
> The router attached to it indicates a 100mbit link. But that's about it.
> I cannot get any data over it. I can manually configure it to have an IP
> address and netmask, but it won't see anything on the local net. DHCP
> doesn't work either. Nothing out of the ordinary is logged in dmesg or
> anywhere else. An usb ethernet dongle on the system works just fine,
> ruling out (absent anyway) firewall or similar trouble.  The device works
> well in windows XP.

Please try the patch below on top of 2.6.23-rc2 ?

> Relevant system specs:
> -Gigabyte GA-G33m-DS2R motherboard, with the integrated realtec nic

Ok, unknown beast.

[...]
> dmesg output:
> 
> r8169 Gigabit Ethernet driver 2.2LK loaded
> ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 17 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:04:00.0 to 64
> eth0: RTL8168b/8111b at 0xf8854000, 00:1a:4d:44:a1:1f, IRQ 18
> ...
> r8169: eth2: link up
> r8169: eth2: link up

Do not hesitate to send a whole dmesg. More context to not hurt.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8be51c4..fecedef 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -789,6 +789,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+		mdio_write(ioaddr, 0x1f, 0x0000);
+		mdio_write(ioaddr, 0x0e, 0x0000);
+	}
+
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
-- 
1.4.4.2

-- 
Ueimor
