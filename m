From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: vxge: Update driver_config->vpath_per_dev for each function in probe.
Date: Mon, 5 Oct 2009 05:06:56 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050506150.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39380 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399AbZJEJ0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Update driver_config->vpath_per_dev for each function in probe.

- vpath_per_device specifies number of vpaths supported for each function/device. The
  current code was updating vpath_per_device only for physical device, however this has
  to be updated for each function also in case of a MF(Multi function) device.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch1/drivers/net/vxge/vxge-main.c patch2/drivers/net/vxge/vxge-main.c
--- patch1/drivers/net/vxge/vxge-main.c	2009-09-03 22:40:14.000000000 -0700
+++ patch2/drivers/net/vxge/vxge-main.c	2009-09-04 01:18:13.000000000 -0700
@@ -4088,9 +4088,10 @@ vxge_probe(struct pci_dev *pdev, const s
 		driver_config->config_dev_cnt = 0;
 		driver_config->total_dev_cnt = 0;
 		driver_config->g_no_cpus = 0;
-		driver_config->vpath_per_dev = max_config_vpath;
 	}
 
+	driver_config->vpath_per_dev = max_config_vpath;
+
 	driver_config->total_dev_cnt++;
 	if (++driver_config->config_dev_cnt > max_config_dev) {
 		ret = 0;

