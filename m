From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] Seved Torstendahl <seved.torstendahl@netinsight.net> suggested to
Date: Thu, 26 Apr 2007 09:22:22 -0700
Message-ID: <20070426162222.17947.98118.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: akpm@osdl.org, jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25534 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031334AbXDZQWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

let the module parameter for invalid eeprom checksum control the valid
mac address test.

If this bypass happens we should print a different message,
or at least one that is correct, maybe something like below

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 1dd1a22..7d9984a 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2597,11 +2597,16 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	memcpy(netdev->dev_addr, nic->eeprom, ETH_ALEN);
 	memcpy(netdev->perm_addr, nic->eeprom, ETH_ALEN);
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "Invalid MAC address from "
-			"EEPROM, aborting.\n");
-		err = -EAGAIN;
-		goto err_out_free;
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
+		if (!eeprom_bad_csum_allow) {
+			DPRINTK(PROBE, ERR, "Invalid MAC address from "
+			        "EEPROM, aborting.\n");
+			err = -EAGAIN;
+			goto err_out_free;
+		} else {
+			DPRINTK(PROBE, ERR, "Invalid MAC address from EEPROM, "
+			        "you MUST configure one.\n");
+		}
 	}
 
 	/* Wol magic packet can be enabled from eeprom */
