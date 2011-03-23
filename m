From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] solos-pci: Don't clear open VCs when we detect carrier
 state (or state changes)
Date: Tue, 22 Mar 2011 23:12:56 -0700
Message-ID: <4D898F68.8020501@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:51968 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751065Ab1CWGNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 02:13:04 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-144-184.ptldor.dsl-w.verizon.net [71.111.144.184])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2N6Cu3B029148
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 00:13:02 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize device state to UP, as is done for Ethernet.  If firmware supports communicating carrier state to us, we'll be notified then, and we can indicate it via atm_dev_signal_change().

In any case: (1) higher level protocols will detect a dead link, and (2) loss of carrier is not a reason to tear down the VCs... this is overly zealous.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
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


