From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [10/10] pasemi_mac: Use local-mac-address instead of mac-address if available
Date: Sat, 28 Apr 2007 15:38:26 -0500
Message-ID: <20070428203826.GK4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50966 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915AbXD1Uht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:37:49 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use local-mac-address in the device tree instead. Fall back to mac-address
for older firmware.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -94,7 +94,12 @@ static int pasemi_get_mac_addr(struct pa
 		return -ENOENT;
 	}
 
-	maddr = get_property(dn, "mac-address", NULL);
+	maddr = get_property(dn, "local-mac-address", NULL);
+
+	/* Fall back to mac-address for older firmware */
+	if (maddr == NULL)
+		maddr = get_property(dn, "mac-address", NULL);
+
 	if (maddr == NULL) {
 		dev_warn(&pdev->dev,
 			 "no mac address in device tree, not configuring\n");
