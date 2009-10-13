From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH 2/2] net: smsc911x: allow platform_data to specify mac address
Date: Tue, 13 Oct 2009 19:25:49 +0200
Message-ID: <1255454749-26895-2-git-send-email-manuel.lauss@gmail.com>
References: <1255454749-26895-1-git-send-email-manuel.lauss@gmail.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:39590 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760688AbZJMR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:26:34 -0400
Received: by ewy4 with SMTP id 4so3602212ewy.37
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 10:25:57 -0700 (PDT)
In-Reply-To: <1255454749-26895-1-git-send-email-manuel.lauss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the driver to accept a MAC address specified in platform_data.

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/smsc911x.c   |    3 +++
 include/linux/smsc911x.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index ccdd196..6a9f51d 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -2071,6 +2071,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	if (is_valid_ether_addr(dev->dev_addr)) {
 		smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 		SMSC_TRACE(PROBE, "MAC Address is specified by configuration");
+	} else if (is_valid_ether_addr(pdata->config.mac)) {
+		memcpy(dev->dev_addr, pdata->config.mac, 6);
+		SMSC_TRACE(PROBE, "MAC Address specified by platform data");
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
 		 * it will already have been set */
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 5241e4f..7144e8a 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -30,6 +30,7 @@ struct smsc911x_platform_config {
 	unsigned int irq_type;
 	unsigned int flags;
 	phy_interface_t phy_interface;
+	unsigned char mac[6];
 };
 
 /* Constants for platform_device irq polarity configuration */
-- 
1.6.5.rc2

