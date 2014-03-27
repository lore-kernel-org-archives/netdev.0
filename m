From: clsoto@linux.vnet.ibm.com
Subject: [Patch 1/3] IB/mlx4: send a IB_EVENT_DEVICE_FATAL to users during PCI error injection
Date: Thu, 27 Mar 2014 09:28:14 -0500
Message-ID: <20140327142939.072593482@linux.vnet.ibm.com>
References: <20140327142813.535289178@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:60985 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1756893AbaC0Ocp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:32:45 -0400
Content-Disposition: inline; filename=mlx4_send_device_fatal_event.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the cards hits a pci error, then notify users that the device is
not in good shape. Send IB_EVENT_DEVICE_FATAL to IB users. 

Signed-off-by: Carol Soto <clsoto@linux.vnet.ibm.com>

---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: b/drivers/net/ethernet/mellanox/mlx4/main.c
===================================================================
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2673,6 +2673,12 @@ MODULE_DEVICE_TABLE(pci, mlx4_pci_table)
 static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 					      pci_channel_state_t state)
 {
+	struct mlx4_dev *dev = pci_get_drvdata(pdev);
+	int i;
+
+	for (i = 1; i <= dev->caps.num_ports; ++i)
+		mlx4_dispatch_event(dev, MLX4_DEV_EVENT_CATASTROPHIC_ERROR, i);
+
 	mlx4_remove_one(pdev);
 
 	return state == pci_channel_io_perm_failure ?

-- 
