From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Fix for kdump
Date: Tue, 16 Nov 2010 16:08:06 -0800
Message-ID: <alpine.OSX.2.00.1011161517110.88679@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:19264 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759093Ab0KQAIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 19:08:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

In case of kdump environment the function may be in unknown state.
Reset the function using PCI FLR before initializing it.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 1cdc05d..3ad1f3e 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -480,6 +480,9 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
 	int err;
 
+	if (reset_devices)
+		pci_reset_function(adapter->pdev);
+
 	err = qlcnic_fw_cmd_create_rx_ctx(adapter);
 	if (err)
 		return err;
-- 
1.5.4.5

