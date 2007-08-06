From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: PHY power-on fix
Date: Tue, 7 Aug 2007 00:21:06 +0200
Message-ID: <20070806222106.GC23302@electric-eye.fr.zoreil.com>
References: <20070806221612.GA23302@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Roger So <roger.so@gmail.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38072 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbXHFWZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 18:25:03 -0400
Content-Disposition: inline
In-Reply-To: <20070806221612.GA23302@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix extracted from Realtek's driver (8.002.00/20070713) for the PHY
attached to 8111/8168b chipsets.

The check against mac_version is just usual paranoia during the bugfix
period of the kernel cycle. -- FR

Tested on Asus M2A-VM motherboard by Roger So.
No regression on my Asrock 945G DVI either (built-in 8168 + 2x8169).

Signed-off-by: Roger So <roger.so@gmail.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bb6896a..ec4f545 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -725,6 +725,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
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

