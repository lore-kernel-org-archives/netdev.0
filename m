From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 03/11] ncsi: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:38:57 +0800
Message-ID: <1497451137-4093-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:35077 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751688AbdFNOkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:40:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ncsi/ncsi-cmd.c | 36 ++++++++++++------------------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index db7083b..010d808 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -66,8 +66,7 @@ static int ncsi_cmd_handler_default(struct sk_buff *skb,
 {
 	struct ncsi_cmd_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -78,8 +77,7 @@ static int ncsi_cmd_handler_sp(struct sk_buff *skb,
 {
 	struct ncsi_cmd_sp_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_sp_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_sp_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->hw_arbitration = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -91,8 +89,7 @@ static int ncsi_cmd_handler_dc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_dc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_dc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_dc_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->ald = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -104,8 +101,7 @@ static int ncsi_cmd_handler_rc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_rc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_rc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_rc_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
 	return 0;
@@ -116,8 +112,7 @@ static int ncsi_cmd_handler_ae(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ae_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ae_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_ae_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mc_id = nca->bytes[0];
 	cmd->mode = htonl(nca->dwords[1]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
@@ -130,8 +125,7 @@ static int ncsi_cmd_handler_sl(struct sk_buff *skb,
 {
 	struct ncsi_cmd_sl_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_sl_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_sl_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	cmd->oem_mode = htonl(nca->dwords[1]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
@@ -144,8 +138,7 @@ static int ncsi_cmd_handler_svf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_svf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_svf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_svf_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->vlan = htons(nca->words[0]);
 	cmd->index = nca->bytes[2];
 	cmd->enable = nca->bytes[3];
@@ -159,8 +152,7 @@ static int ncsi_cmd_handler_ev(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ev_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ev_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_ev_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -173,8 +165,7 @@ static int ncsi_cmd_handler_sma(struct sk_buff *skb,
 	struct ncsi_cmd_sma_pkt *cmd;
 	int i;
 
-	cmd = (struct ncsi_cmd_sma_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_sma_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	for (i = 0; i < 6; i++)
 		cmd->mac[i] = nca->bytes[i];
 	cmd->index = nca->bytes[6];
@@ -189,8 +180,7 @@ static int ncsi_cmd_handler_ebf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_ebf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_ebf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_ebf_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -202,8 +192,7 @@ static int ncsi_cmd_handler_egmf(struct sk_buff *skb,
 {
 	struct ncsi_cmd_egmf_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_egmf_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_egmf_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = htonl(nca->dwords[0]);
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
@@ -215,8 +204,7 @@ static int ncsi_cmd_handler_snfc(struct sk_buff *skb,
 {
 	struct ncsi_cmd_snfc_pkt *cmd;
 
-	cmd = (struct ncsi_cmd_snfc_pkt *)skb_put(skb, sizeof(*cmd));
-	memset(cmd, 0, sizeof(*cmd));
+	cmd = (struct ncsi_cmd_snfc_pkt *)skb_put_zero(skb, sizeof(*cmd));
 	cmd->mode = nca->bytes[0];
 	ncsi_cmd_build_header(&cmd->cmd.common, nca);
 
-- 
2.7.4
