From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2 v2] qlcnic: remove dead code
Date: Wed, 18 Dec 2013 13:55:46 -0800
Message-ID: <20131218135546.4ba725cf@nehalam.linuxnetplumber.net>
References: <20131213123119.16358e1b@nehalam.linuxnetplumber.net>
	<1902752B0C92F943AB7EA9EE13E2DEEC1273B9F4A5@HQ1-EXCH02.corp.brocade.com>
	<20131218135438.71ea917f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61137 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399Ab3LRVz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:55:58 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so224956pdj.33
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 13:55:58 -0800 (PST)
In-Reply-To: <20131218135438.71ea917f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove function  qlcnic_enable_eswitch which was defined
but never used in current code.

Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c |   30 --------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h |    1 
 2 files changed, 31 deletions(-)

--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2013-12-18 13:32:21.098021506 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2013-12-18 13:33:15.497246711 -0800
@@ -2186,36 +2186,6 @@ out:
 	return IRQ_HANDLED;
 }
 
-int qlcnic_enable_eswitch(struct qlcnic_adapter *adapter, u8 port, u8 enable)
-{
-	int err = -EIO;
-	struct qlcnic_cmd_args cmd;
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
-		dev_err(&adapter->pdev->dev,
-			"%s: Error, invoked by non management func\n",
-			__func__);
-		return err;
-	}
-
-	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_TOGGLE_ESWITCH);
-	if (err)
-		return err;
-
-	cmd.req.arg[1] = (port & 0xf) | BIT_4;
-	err = qlcnic_issue_cmd(adapter, &cmd);
-
-	if (err != QLCNIC_RCODE_SUCCESS) {
-		dev_err(&adapter->pdev->dev, "Failed to enable eswitch%d\n",
-			err);
-		err = -EIO;
-	}
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-
-}
-
 int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *adapter,
 			     struct qlcnic_info *nic)
 {
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2013-12-18 13:32:21.098021506 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2013-12-18 13:33:15.497246711 -0800
@@ -588,7 +588,6 @@ void qlcnic_83xx_disable_intr(struct qlc
 			     struct qlcnic_host_sds_ring *);
 void qlcnic_83xx_check_vf(struct qlcnic_adapter *,
 			  const struct pci_device_id *);
-int qlcnic_enable_eswitch(struct qlcnic_adapter *, u8, u8);
 int qlcnic_83xx_config_default_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *);
 void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *);
