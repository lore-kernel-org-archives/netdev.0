From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH] dm9000: Support MAC address setting through platform data.
Date: Wed, 23 Jul 2008 17:41:52 +0200
Message-ID: <200807231741.53011.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:20107 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751797AbYGWPl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 11:41:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dm9000 driver reads the chip's MAC address from the attached EEPROM. When
no EEPROM is present, or when the MAC address is invalid, it falls back to
reading the address from the chip.

This patch lets platform code set the desired MAC address through platform
data.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
---
 drivers/net/dm9000.c   |    3 +++
 include/linux/dm9000.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 864295e..6bc8924 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -716,6 +716,11 @@ dm9000_probe(struct platform_device *pdev)
 	for (i = 0; i < 6; i += 2)
 		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
 
+	if (!is_valid_ether_addr(ndev->dev_addr) && pdata != NULL) {
+		mac_src = "platform data";
+		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
+	}
+
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
 		
diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
index a375046..4fb49a4 100644
--- a/include/linux/dm9000.h
+++ b/include/linux/dm9000.h
@@ -26,6 +26,7 @@
 
 struct dm9000_plat_data {
 	unsigned int	flags;
+	unsigned char	dev_addr[6];
 
 	/* allow replacement IO routines */
 
-- 
1.5.0

-- 
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
F +32 (2) 387 42 75
