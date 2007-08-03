From: Li Yang <leoli@freescale.com>
Subject: [GIT PATCH] ucc_geth fixes for 2.6.22-rc1
Date: Fri, 03 Aug 2007 17:07:55 +0800
Message-ID: <1186132075.6230.11.camel@Gundam>
Reply-To: leoli@freescale.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:37957 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbXHCI5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 04:57:13 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l738v9h8013781
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2007 01:57:09 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l738v7ec012021
	for <netdev@vger.kernel.org>; Fri, 3 Aug 2007 03:57:08 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from 'ucc_geth' branch of
master.kernel.org:/pub/scm/linux/kernel/git/leo/fsl-soc.git ucc_geth

to receive the following fixes:

 drivers/net/ucc_geth_ethtool.c |    1 -
 drivers/net/ucc_geth_mii.c     |    3 ++-
 2 files changed, 2 insertions(+), 2 deletions(-)

Domen Puncer (1):
      ucc_geth: fix section mismatch

Jan Altenberg (1):
      ucc_geth: remove get_perm_addr from ucc_geth_ethtool.c


diff --git a/drivers/net/ucc_geth_ethtool.c
b/drivers/net/ucc_geth_ethtool.c
index a8994c7..64bef7c 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -379,7 +379,6 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_stats_count        = uec_get_stats_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
-	.get_perm_addr          = ethtool_op_get_perm_addr,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 5f8c2d3..6c257b8 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -272,7 +272,8 @@ int __init uec_mdio_init(void)
 	return of_register_platform_driver(&uec_mdio_driver);
 }
 
-void __exit uec_mdio_exit(void)
+/* called from __init ucc_geth_init, therefore can not be __exit */
+void uec_mdio_exit(void)
 {
 	of_unregister_platform_driver(&uec_mdio_driver);
 }

