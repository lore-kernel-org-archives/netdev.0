From: anirban.chakraborty@qlogic.com
Subject: [PATCH 2/9 net-next-2.6] qlcnic: Memory leak fix
Date: Fri,  1 Apr 2011 17:07:09 -0700
Message-ID: <1301702836-3265-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: davem@davemloft.com, Dept_NX_Linux_NIC_driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:34114 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753995Ab1DBAZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 20:25:16 -0400
In-Reply-To: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix a memory leak in error path of pci info.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com
---
 drivers/net/qlcnic/qlcnic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index d230fdd..de6f866 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -464,8 +464,10 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		pfn = pci_info[i].id;
-		if (pfn > QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
+		if (pfn > QLCNIC_MAX_PCI_FUNC) {
+			ret = QL_STATUS_INVALID_PARAM;
+			goto err_eswitch;
+		}
 		adapter->npars[pfn].active = (u8)pci_info[i].active;
 		adapter->npars[pfn].type = (u8)pci_info[i].type;
 		adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
-- 
1.7.1

