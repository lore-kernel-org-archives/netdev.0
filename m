From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 2/4] vxge: Allow driver load for all enumerated
 pci functions.
Date: Thu, 8 Apr 2010 04:43:37 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11004080442170.365-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38540 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880Ab0DHInj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Allow all instances of the driver be loaded when multiple pci functions are
enumerated. The max_config_dev driver loadable option limits the driver
load instances if required. The X3100's function configuration of single/multi
function, SR and MR IOV allows the user to select the number of pci functions.
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
diff -urpN patch1/drivers/net/vxge/vxge-main.c patch2/drivers/net/vxge/vxge-main.c
--- patch1/drivers/net/vxge/vxge-main.c	2010-04-01 12:04:00.000000000 +0530
+++ patch2/drivers/net/vxge/vxge-main.c	2010-04-01 12:12:50.000000000 +0530
@@ -4016,9 +4016,11 @@ vxge_probe(struct pci_dev *pdev, const s
 				driver_config->total_dev_cnt);
 		driver_config->config_dev_cnt = 0;
 		driver_config->total_dev_cnt = 0;
-		driver_config->g_no_cpus = 0;
 	}
-
+	/* Now making the CPU based no of vpath calculation
+	 * applicable for individual functions as well.
+	 */
+	driver_config->g_no_cpus = 0;
 	driver_config->vpath_per_dev = max_config_vpath;
 
 	driver_config->total_dev_cnt++;

