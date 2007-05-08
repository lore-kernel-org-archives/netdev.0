From: Olof Johansson <olof@lixom.net>
Subject: [PATCH v4 9/9] pasemi_mac: Use local-mac-address instead of mac-address if available
Date: Tue, 8 May 2007 00:48:02 -0500
Message-ID: <20070508054802.GJ14321@lixom.net>
References: <20070508053500.358169000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:32965 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbXEHGIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 02:08:44 -0400
Content-Disposition: inline; filename=n-10
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

--
