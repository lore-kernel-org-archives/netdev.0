From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/5] netxen: fix firmware reset logic
Date: Sun, 23 Aug 2009 11:35:10 -0700
Message-ID: <1251052513-27618-2-git-send-email-dhananjay@netxen.com>
References: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:19507 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933763AbZHWSfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 14:35:13 -0400
In-Reply-To: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If netxen_need_fw_reset() return 0 [ implies firmware is up
and running], still go through dma mask check, etc.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index de67e42..0086574 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -754,8 +754,10 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 		netxen_request_firmware(adapter);
 
 	err = netxen_need_fw_reset(adapter);
-	if (err <= 0)
+	if (err < 0)
 		return err;
+	if (err == 0)
+		goto wait_init;
 
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
-- 
1.6.0.2

