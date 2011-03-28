From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 2/2] solos-pci: Initialize carrier state up and don't drop
 VCs on carrier transition
Date: Sun, 27 Mar 2011 22:23:57 -0700
Message-ID: <4D901B6D.4020107@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54105 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752587Ab1C1FYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 01:24:05 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-146-59.ptldor.dsl-w.verizon.net [71.111.146.59])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2S5Nvdr019249
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 23:24:03 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Don't drop VCs when carrier state changes.

Signed-off-by: Philip Prindeville<philipp@redfish-solutions.com>
---
  drivers/atm/solos-pci.c |    3 +--
  1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 265bbdf..cd0ff66 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -383,7 +383,6 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
  	/* Anything but 'Showtime' is down */
  	if (strcmp(state_str, "Showtime")) {
  		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
-		atm_dev_release_vccs(card->atmdev[port]);
  		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
  		return 0;
  	}
@@ -1246,7 +1245,7 @@ static int atm_init(struct solos_card *card, struct device *parent)
  		card->atmdev[i]->ci_range.vci_bits = 16;
  		card->atmdev[i]->dev_data = card;
  		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
-		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_UNKNOWN);
+		atm_dev_signal_change(card->atmdev[i], ATM_PHY_SIG_FOUND);

  		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
  		if (!skb) {


