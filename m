From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/4] enic: fix location of vnic dev unregister in
	enic_probe cleanup code
Date: Wed, 18 Jan 2012 06:24:12 -0800
Message-ID: <20120118142412.7877.71376.stgit@rhel6.1>
References: <20120118142336.7877.67031.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:40437 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab2ARGkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:40:18 -0500
In-Reply-To: <20120118142336.7877.67031.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

The vnic_dev_unregister is erroneously under CONFIG_PCI_IOV. This patch moves
it out of CONFIG_PCI_IOV

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 03b0577..045c468 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2531,8 +2531,8 @@ err_out_disable_sriov_pp:
 		enic->priv_flags &= ~ENIC_SRIOV_ENABLED;
 	}
 err_out_vnic_unregister:
-	vnic_dev_unregister(enic->vdev);
 #endif
+	vnic_dev_unregister(enic->vdev);
 err_out_iounmap:
 	enic_iounmap(enic);
 err_out_release_regions:
