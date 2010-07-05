From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v2 5/9] atm/solos-pci: call atm_dev_signal_change() when signal changes.
Date: Mon,  5 Jul 2010 10:45:57 +0200
Message-ID: <1278319561-23548-6-git-send-email-karl@hiramoto.org>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:44166 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758160Ab0GEIsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:48:08 -0400
Received: from homiemail-a30.g.dreamhost.com (caiajhbdcbhh.dreamhost.com [208.97.132.177])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 834A817A217
	for <netdev@vger.kernel.org>; Mon,  5 Jul 2010 01:48:06 -0700 (PDT)
In-Reply-To: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate changes to upper atm layer, so userspace netmontor knows when DSL
showtime reached.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/atm/solos-pci.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index ded76c4..6174965 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -383,7 +383,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 
 	/* Anything but 'Showtime' is down */
 	if (strcmp(state_str, "Showtime")) {
-		card->atmdev[port]->signal = ATM_PHY_SIG_LOST;
+		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
 		release_vccs(card->atmdev[port]);
 		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
 		return 0;
@@ -401,7 +401,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 		 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
 	
 	card->atmdev[port]->link_rate = rate_down / 424;
-	card->atmdev[port]->signal = ATM_PHY_SIG_FOUND;
+	atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_FOUND);
 
 	return 0;
 }
@@ -1246,7 +1246,7 @@ static int atm_init(struct solos_card *card)
 		card->atmdev[i]->ci_range.vci_bits = 16;
 		card->atmdev[i]->dev_data = card;
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
-		card->atmdev[i]->signal = ATM_PHY_SIG_UNKNOWN;
+		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_UNKNOWN);
 
 		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 		if (!skb) {
-- 
1.7.1

