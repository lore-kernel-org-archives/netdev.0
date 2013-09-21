From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 11/19] wireless: Change variable type to bool
Date: Sun, 22 Sep 2013 00:27:43 +0200
Message-ID: <1379802471-30252-11-git-send-email-peter.senna@gmail.com>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: bzhao@marvell.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variables cancel_scan_cmd, enable_data, hs_activate and valid are
only assigned the values true and false. Change its type to bool.

The simplified semantic patch that find this problem is as
follows (http://coccinelle.lip6.fr/):

@exists@
type T;
identifier b;
@@
- T
+ bool
  b = ...;
  ... when any
  b = \(true\|false\)

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
 drivers/net/wireless/mwifiex/cmdevt.c  | 2 +-
 drivers/net/wireless/mwifiex/join.c    | 2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c | 2 +-
 drivers/net/wireless/mwifiex/wmm.c     | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/mwifiex/cmdevt.c
index 2d76147..fb3fa18 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -1048,7 +1048,7 @@ mwifiex_cancel_pending_ioctl(struct mwifiex_adapter *adapter)
 	struct cmd_ctrl_node *cmd_node = NULL, *tmp_node = NULL;
 	unsigned long cmd_flags;
 	unsigned long scan_pending_q_flags;
-	uint16_t cancel_scan_cmd = false;
+	bool cancel_scan_cmd = false;
 
 	if ((adapter->curr_cmd) &&
 	    (adapter->curr_cmd->wait_q_enabled)) {
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
index 9d7c0e6..717fbe2 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -621,7 +621,7 @@ int mwifiex_ret_802_11_associate(struct mwifiex_private *priv,
 	int ret = 0;
 	struct ieee_types_assoc_rsp *assoc_rsp;
 	struct mwifiex_bssdescriptor *bss_desc;
-	u8 enable_data = true;
+	bool enable_data = true;
 	u16 cap_info, status_code;
 
 	assoc_rsp = (struct ieee_types_assoc_rsp *) &resp->params;
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
index c0268b5..7d66018 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -327,7 +327,7 @@ mwifiex_cmd_802_11_hs_cfg(struct mwifiex_private *priv,
 {
 	struct mwifiex_adapter *adapter = priv->adapter;
 	struct host_cmd_ds_802_11_hs_cfg_enh *hs_cfg = &cmd->params.opt_hs_cfg;
-	u16 hs_activate = false;
+	bool hs_activate = false;
 
 	if (!hscfg_param)
 		/* New Activate command */
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwifiex/wmm.c
index 2e8f9cd..8f8fea0 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -708,7 +708,7 @@ int mwifiex_ret_wmm_get_status(struct mwifiex_private *priv,
 {
 	u8 *curr = (u8 *) &resp->params.get_wmm_status;
 	uint16_t resp_len = le16_to_cpu(resp->size), tlv_len;
-	int valid = true;
+	bool valid = true;
 
 	struct mwifiex_ie_types_data *tlv_hdr;
 	struct mwifiex_ie_types_wmm_queue_status *tlv_wmm_qstatus;
-- 
1.8.3.1

