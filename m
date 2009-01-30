From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/5] forcedeth: msi interrupt fix
Date: Fri, 30 Jan 2009 13:56:30 -0500
Message-ID: <49834D5E.9010104@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060706030507070604000609"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:13930 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501AbZA3WB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:01:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060706030507070604000609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an issue with the suspend/resume cycle with msi 
interrupts. See bugzilla number 10487 for more details. The fix is to 
re-setup a private msi pci config offset field.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------060706030507070604000609
Content-Type: text/plain;
 name="patch-forcedeth-msi-pci-config"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msi-pci-config"

--- old/drivers/net/forcedeth.c	2009-01-27 10:48:18.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-01-27 10:48:21.000000000 -0800
@@ -589,6 +589,9 @@
 #define NV_MSI_X_VECTOR_TX    0x1
 #define NV_MSI_X_VECTOR_OTHER 0x2
 
+#define NV_MSI_PRIV_OFFSET 0x68
+#define NV_MSI_PRIV_VALUE  0xffffffff
+
 #define NV_RESTART_TX         0x1
 #define NV_RESTART_RX         0x2
 
@@ -6057,6 +6060,8 @@
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
+	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
+
 	netif_device_attach(dev);
 	if (netif_running(dev)) {
 		rc = nv_open(dev);

--------------060706030507070604000609--
