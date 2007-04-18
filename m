From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [5/5] [v2] pasemi_mac: use local-mac-address
Date: Wed, 18 Apr 2007 01:27:50 -0500
Message-ID: <20070418062750.GF11308@lixom.net>
References: <20070416061654.GB19783@lixom.net> <20070418062451.GA11308@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:37201 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019AbXDRGJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:09:29 -0400
Content-Disposition: inline
In-Reply-To: <20070418062451.GA11308@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use local-mac-address in the device tree instead. Fall back to mac-address
for older firmware.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: powerpc/drivers/net/pasemi_mac.c
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.c
+++ powerpc/drivers/net/pasemi_mac.c
@@ -74,7 +74,12 @@ static int pasemi_get_mac_addr(struct pa
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
