From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/5] forcedeth: msi interrupt fix
Date: Fri, 06 Feb 2009 14:27:24 -0500
Message-ID: <498C8F1C.2000108@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050703030606050303050404"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19116 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbZBFW2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:28:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050703030606050303050404
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an issue with the suspend/resume cycle with msi
interrupts. See bugzilla number 10487 for more details. The fix is to
re-setup a private msi pci config offset field.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>




--------------050703030606050303050404
Content-Type: text/plain;
 name="patch-forcedeth-msi-pci-config"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msi-pci-config"

--- old/drivers/net/forcedeth.c	2009-02-06 14:14:02.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-02-06 14:14:54.000000000 -0500
@@ -589,6 +589,9 @@
 #define NV_MSI_X_VECTOR_TX    0x1
 #define NV_MSI_X_VECTOR_OTHER 0x2
 
+#define NV_MSI_PRIV_OFFSET 0x68
+#define NV_MSI_PRIV_VALUE  0xffffffff
+
 #define NV_RESTART_TX         0x1
 #define NV_RESTART_RX         0x2
 
@@ -6074,6 +6077,8 @@
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
+	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
+
 	netif_device_attach(dev);
 	if (netif_running(dev)) {
 		rc = nv_open(dev);

--------------050703030606050303050404--
