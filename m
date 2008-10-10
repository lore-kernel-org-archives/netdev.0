From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/14] r8169: wake up the PHY of the 8168
Date: Fri, 10 Oct 2008 23:38:13 +0200
Message-ID: <20081010213813.GA27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw, RyanKao <ryankao@realtek.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40734 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760911AbYJJVjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:39:33 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is typically needed when some other OS puts the PHY
to sleep due to the disabling of WOL options in the BIOS
of the system.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Chiaki Ishikawa <chiaki.ishikawa@ubin.jp>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
Cc: RyanKao <ryankao@realtek.com.tw>
---
 drivers/net/r8169.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59fbc64..9881563 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -865,9 +865,13 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
+		/*
+		 * Wake up the PHY.
+		 * Vendor specific (0x1f) and reserved (0x0e) MII registers.
+		 */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
 	}
-- 
1.5.3.3

