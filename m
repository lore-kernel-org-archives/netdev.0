From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 3/6] be2net: remove a BUG_ON in be_cmds.c
Date: Sun, 22 Aug 2010 14:55:38 +0530
Message-ID: <20100822092529.GA22268@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2210 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab0HVJZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 05:25:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Async notifications other than link status are possible in certain
configurations. Remove the BUG_ON.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 3d30549..22bd062 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -140,10 +140,8 @@ int be_process_mcc(struct be_adapter *adapter, int *status)
 	while ((compl = be_mcc_compl_get(adapter))) {
 		if (compl->flags & CQE_FLAGS_ASYNC_MASK) {
 			/* Interpret flags as an async trailer */
-			BUG_ON(!is_link_state_evt(compl->flags));
-
-			/* Interpret compl as a async link evt */
-			be_async_link_state_process(adapter,
+			if (is_link_state_evt(compl->flags))
+				be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
 				*status = be_mcc_compl_process(adapter, compl);
-- 
1.7.0.4

