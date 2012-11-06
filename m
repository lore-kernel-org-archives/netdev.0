From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net] cxgb4: Initialize data structures before using.
Date: Tue,  6 Nov 2012 19:07:09 +0530
Message-ID: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24883 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab2KFNkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 08:40:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not assume reserve fields to be don't cares as fields may change.
Clearing data structures before using.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 32eec15..01fa5b7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2519,6 +2519,7 @@ int t4_fw_bye(struct adapter *adap, unsigned int mbox)
 {
 	struct fw_bye_cmd c;
 
+	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, BYE, WRITE);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -2535,6 +2536,7 @@ int t4_early_init(struct adapter *adap, unsigned int mbox)
 {
 	struct fw_initialize_cmd c;
 
+	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, INITIALIZE, WRITE);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -2551,6 +2553,7 @@ int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset)
 {
 	struct fw_reset_cmd c;
 
+	memset(&c, 0, sizeof(c));
 	INIT_CMD(c, RESET, WRITE);
 	c.val = htonl(reset);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
@@ -3278,6 +3281,7 @@ int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
 {
 	struct fw_vi_enable_cmd c;
 
+	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST |
 			     FW_CMD_EXEC | FW_VI_ENABLE_CMD_VIID(viid));
 	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_LED | FW_LEN16(c));
-- 
1.7.1
