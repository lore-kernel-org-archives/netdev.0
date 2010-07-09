From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 2/2] qlcnic: Disable admin tools interface for
 VF driver mode
Date: Fri, 9 Jul 2010 16:15:05 -0700
Message-ID: <alpine.OSX.2.00.1007091611371.44317@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:24526 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab0GIXPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 19:15:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Non privileged (VF) driver will not be able to carry out any of the FW update,
etc. operations. Disable the tools interface by not creating the sysfs nodes.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index c334f1a..4d18313 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3272,6 +3272,8 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
 		dev_info(dev, "failed to create diag_mode sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_crb))
@@ -3292,12 +3294,13 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 
 }
 
-
 static void
 qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
-- 
1.7.1

