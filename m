From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] qlcnic: remove unused code
Date: Thu, 16 Jan 2014 10:32:21 -0800
Message-ID: <20140116103221.41637f8f@nehalam.linuxnetplumber.net>
References: <20140116103127.121855af@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44923 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaAPSc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 13:32:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so3005829pab.23
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 10:32:28 -0800 (PST)
In-Reply-To: <20140116103127.121855af@nehalam.linuxnetplumber.net>
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

--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-16 09:59:06.005043766 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-16 09:59:20.612876755 -0800
@@ -2196,36 +2196,6 @@ out:
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
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2014-01-16 09:58:55.213189820 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h	2014-01-16 09:59:20.612876755 -0800
@@ -590,7 +590,6 @@ void qlcnic_83xx_disable_intr(struct qlc
 			     struct qlcnic_host_sds_ring *);
 void qlcnic_83xx_check_vf(struct qlcnic_adapter *,
 			  const struct pci_device_id *);
-int qlcnic_enable_eswitch(struct qlcnic_adapter *, u8, u8);
 int qlcnic_83xx_config_default_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *);
 void qlcnic_83xx_free_mbx_intr(struct qlcnic_adapter *);
