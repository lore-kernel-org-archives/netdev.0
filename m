From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 3/9] vxge: check for card status before continuing
 in device close
Date: Thu, 2 Jul 2009 03:14:03 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020313180.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37772 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZGBH0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:26:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixed the crash in rmmod after vpath open failed when trying to change mtu.
We should check for card status before continuing in device close.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_2/drivers/net/vxge/vxge-main.c patch_3/drivers/net/vxge/vxge-main.c
--- patch_2/drivers/net/vxge/vxge-main.c	2009-06-21 23:43:43.000000000 -0700
+++ patch_3/drivers/net/vxge/vxge-main.c	2009-06-21 23:50:01.000000000 -0700
@@ -2890,6 +2890,9 @@ int do_vxge_close(struct net_device *dev
 	vdev = (struct vxgedev *)netdev_priv(dev);
 	hldev = (struct __vxge_hw_device *) pci_get_drvdata(vdev->pdev);
 
+	if (unlikely(!is_vxge_card_up(vdev)))
+		return 0;
+
 	/* If vxge_handle_crit_err task is executing,
 	 * wait till it completes. */
 	while (test_and_set_bit(__VXGE_STATE_RESET_CARD, &vdev->state))

