From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/2] Pull request for 'r8169-davem' branch
Date: Sun, 20 Jul 2008 20:04:51 +0200
Message-ID: <20080720180451.GA31465@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Marcus Sundberg <marcus@ingate.com>,
	Johan =?unknown-8bit?Q?Myr=C3=A9en?= <jem@iki.fi>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35143 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757891AbYGTSHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 14:07:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r8169-davem' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

to get the changes below.

Distance from 'davem' (fb65a7c091529bfffb1262515252c0d0f6241c5c)
----------------------------------------------------------------

77332894c21165404496c56763d7df6c15c4bb09
f887cce8de019bb32917789379af89ae4c0294ee

Diffstat
--------

 drivers/net/r8169.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: multicast register update

Marcus Sundberg (1):
      r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index cfe8829..a3e3895 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1418,8 +1418,10 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl_hw_phy_config(dev);
 
-	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
-	RTL_W8(0x82, 0x01);
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06) {
+		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+		RTL_W8(0x82, 0x01);
+	}
 
 	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 
@@ -3032,13 +3034,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	tmp = rtl8169_rx_config | rx_mode |
 	      (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
 		u32 data = mc_filter[0];
 
 		mc_filter[0] = swab32(mc_filter[1]);
-- 
Ueimor
