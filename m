From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 4/8] vxge: Fixed "ethtool -d" prints.
Date: Mon, 29 Mar 2010 04:10:33 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11003290409530.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48123 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab0C2IXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:23:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed "ethtool -d" prints
- reg_space pointer was getting over written, updating it correctly.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch3/drivers/net/vxge/vxge-ethtool.c patch4/drivers/net/vxge/vxge-ethtool.c
--- patch3/drivers/net/vxge/vxge-ethtool.c	2010-03-19 16:17:46.000000000 +0530
+++ patch4/drivers/net/vxge/vxge-ethtool.c	2010-03-19 16:22:15.000000000 +0530
@@ -108,7 +108,7 @@ static void vxge_ethtool_gregs(struct ne
 	int index, offset;
 	enum vxge_hw_status status;
 	u64 reg;
-	u8 *reg_space = (u8 *) space;
+	u64 *reg_space = (u64 *) space;
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
 	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device *)
 					pci_get_drvdata(vdev->pdev);
@@ -128,8 +128,7 @@ static void vxge_ethtool_gregs(struct ne
 						__func__, __LINE__);
 				return;
 			}
-
-			memcpy((reg_space + offset), &reg, 8);
+			*reg_space++ = reg;
 		}
 	}
 }

