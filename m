From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 6/8] mwl8k: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 10:58:37 +0200
Message-ID: <1247734717-21008-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	ramirose@gmail.com, buytenh@marvell.com, jal2@gmx.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:59612 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754429AbZGPI6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 04:58:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM conversion specifier for printk instead of print_mac.

Also remove an unused DECLARE_MAC_BUF declaration.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/mwl8k.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index a263d5c..43dcfaf 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -2270,7 +2270,6 @@ static int mwl8k_cmd_update_sta_db(struct ieee80211_hw *hw,
 	struct mwl8k_cmd_update_sta_db *cmd;
 	struct peer_capability_info *peer_info;
 	struct ieee80211_rate *bitrates = mv_vif->legacy_rates;
-	DECLARE_MAC_BUF(mac);
 	int rc;
 	__u8 count, *rates;
 
@@ -3479,7 +3478,6 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 {
 	struct ieee80211_hw *hw;
 	struct mwl8k_priv *priv;
-	DECLARE_MAC_BUF(mac);
 	int rc;
 	int i;
 	u8 *fw;
@@ -3668,8 +3666,8 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 		MWL8K_DESC);
 	printk(KERN_INFO "%s: Driver Ver:%s  Firmware Ver:%u.%u.%u.%u\n",
 		priv->name, MWL8K_VERSION, fw[3], fw[2], fw[1], fw[0]);
-	printk(KERN_INFO "%s: MAC Address: %s\n", priv->name,
-	       print_mac(mac, hw->wiphy->perm_addr));
+	printk(KERN_INFO "%s: MAC Address: %pM\n", priv->name,
+		hw->wiphy->perm_addr);
 
 	return 0;
 
-- 
1.6.0.4

