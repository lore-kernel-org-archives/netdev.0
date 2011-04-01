From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 1/9 net-next-2.6] qlcnic: Make PCI info available in all modes
Date: Fri, 1 Apr 2011 15:56:23 -0700
Message-ID: <1301698583-8469-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:48900
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750766Ab1DAW5V convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 18:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Before this fix, PCI info was available only when multiple NIC functions
are present on the same port.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index cd88c7e..d230fdd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3954,14 +3954,14 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
                dev_info(dev, "failed to create crb sysfs entry\n");
        if (device_create_bin_file(dev, &bin_attr_mem))
                dev_info(dev, "failed to create mem sysfs entry\n");
+       if (device_create_bin_file(dev, &bin_attr_pci_config))
+               dev_info(dev, "failed to create pci config sysfs entry");
        if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
                return;
        if (device_create_bin_file(dev, &bin_attr_esw_config))
                dev_info(dev, "failed to create esw config sysfs entry");
        if (adapter->op_mode != QLCNIC_MGMT_FUNC)
                return;
-       if (device_create_bin_file(dev, &bin_attr_pci_config))
-               dev_info(dev, "failed to create pci config sysfs entry");
        if (device_create_bin_file(dev, &bin_attr_npar_config))
                dev_info(dev, "failed to create npar config sysfs entry");
        if (device_create_bin_file(dev, &bin_attr_pm_config))
@@ -3982,12 +3982,12 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
        device_remove_file(dev, &dev_attr_diag_mode);
        device_remove_bin_file(dev, &bin_attr_crb);
        device_remove_bin_file(dev, &bin_attr_mem);
+       device_remove_bin_file(dev, &bin_attr_pci_config);
        if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
                return;
        device_remove_bin_file(dev, &bin_attr_esw_config);
        if (adapter->op_mode != QLCNIC_MGMT_FUNC)
                return;
-       device_remove_bin_file(dev, &bin_attr_pci_config);
        device_remove_bin_file(dev, &bin_attr_npar_config);
        device_remove_bin_file(dev, &bin_attr_pm_config);
        device_remove_bin_file(dev, &bin_attr_esw_stats);
--
1.7.1


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

