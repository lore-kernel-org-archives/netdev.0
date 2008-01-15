From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] ne2k: add minimal ethtool setting support
Date: Tue, 15 Jan 2008 15:48:05 -0800
Message-ID: <20080115154805.69150f76@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35662 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758208AbYAOXuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 18:50:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add minimal ethtool settings support for ne2k driver. This is needed
for KVM/QEMU environment where ne2k seems to be the simplest stupid
hardware used.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

--- a/drivers/net/ne2k-pci.c	2008-01-15 11:21:02.000000000 -0800
+++ b/drivers/net/ne2k-pci.c	2008-01-15 15:43:17.000000000 -0800
@@ -634,8 +634,21 @@ static void ne2k_pci_get_drvinfo(struct 
 	strcpy(info->bus_info, pci_name(pci_dev));
 }
 
+static int ne2k_pci_get_settings(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
+{
+	cmd->speed		= SPEED_10;
+	cmd->duplex		= (ei_status.ne2k_flags & FORCE_FDX)
+				   ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->port		= PORT_TP;
+	cmd->transceiver	= XCVR_INTERNAL;
+	cmd->autoneg		= AUTONEG_DISABLE;
+	return 0;
+}
+
 static const struct ethtool_ops ne2k_pci_ethtool_ops = {
 	.get_drvinfo		= ne2k_pci_get_drvinfo,
+	.get_settings		= ne2k_get_settings,
 };
 
 static void __devexit ne2k_pci_remove_one (struct pci_dev *pdev)


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
