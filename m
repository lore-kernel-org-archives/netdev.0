From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] qla3xxx: device doesnt do hardware checksumming.
Date: Wed, 30 May 2007 14:23:17 -0700
Message-ID: <20070530212512.118483672@linux-foundation.org>
References: <20070530212316.407169588@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:49104 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758392AbXE3ViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 17:38:08 -0400
Content-Disposition: inline; filename=qla-ipv6.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reading the code for ql_hw_csum_setup(), it is obvious that
this driver is broken for IPV6. The driver sets the NETIF_F_HW_SUM
flag, but the code for checksum setup only deals with IPV4.

Compile tested only, no hardware available.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/qla3xxx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/qla3xxx.c	2007-05-30 14:05:12.000000000 -0700
+++ b/drivers/net/qla3xxx.c	2007-05-30 14:09:25.000000000 -0700
@@ -4044,7 +4044,7 @@ static int __devinit ql3xxx_probe(struct
 	if (pci_using_dac)
 		ndev->features |= NETIF_F_HIGHDMA;
 	if (qdev->device_id == QL3032_DEVICE_ID)
-		ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_SG);
+		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
 	qdev->mem_map_registers =
 	    ioremap_nocache(pci_resource_start(pdev, 1),

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

