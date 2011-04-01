From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 2/9 net-next-2.6] qlcnic: mem free bug fix in error path
Date: Thu, 31 Mar 2011 21:34:16 -0700
Message-ID: <alpine.OSX.2.00.1103312132580.47460@n5102mn2hhgf91.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:22005
	"EHLO VA3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab1DAEfR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 00:35:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix a memory leak in error path.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
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
-               if (pfn > QLCNIC_MAX_PCI_FUNC)
-                       return QL_STATUS_INVALID_PARAM;
+               if (pfn > QLCNIC_MAX_PCI_FUNC) {
+                       ret = QL_STATUS_INVALID_PARAM;
+                       goto err_eswitch;
+               }
                adapter->npars[pfn].active = (u8)pci_info[i].active;
                adapter->npars[pfn].type = (u8)pci_info[i].type;
                adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
--
1.7.4.1


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

