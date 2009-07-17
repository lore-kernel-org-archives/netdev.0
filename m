From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] b44: strncpy does not null terminate string
Date: Fri, 17 Jul 2009 20:01:54 +0200
Message-ID: <4A60BC92.7030406@gmail.com>
References: <4A607185.6020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: zambrano@broadcom.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:58778 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964965AbZGQSAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 14:00:01 -0400
Received: by ewy26 with SMTP id 26so1049815ewy.37
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 11:00:00 -0700 (PDT)
In-Reply-To: <4A607185.6020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

strlcpy() will always null terminate the string. Also use the
sizeof(version) to strlcopy() the version string.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 36d4d37..1f7f015 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1756,15 +1756,15 @@ static void b44_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *inf
 	struct b44 *bp = netdev_priv(dev);
 	struct ssb_bus *bus = bp->sdev->bus;
 
-	strncpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
-	strncpy(info->version, DRV_MODULE_VERSION, sizeof(info->driver));
+	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 	switch (bus->bustype) {
 	case SSB_BUSTYPE_PCI:
-		strncpy(info->bus_info, pci_name(bus->host_pci), sizeof(info->bus_info));
+		strlcpy(info->bus_info, pci_name(bus->host_pci), sizeof(info->bus_info));
 		break;
 	case SSB_BUSTYPE_PCMCIA:
 	case SSB_BUSTYPE_SSB:
-		strncpy(info->bus_info, "SSB", sizeof(info->bus_info));
+		strlcpy(info->bus_info, "SSB", sizeof(info->bus_info));
 		break;
 	}
 }
