From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 4/4] cxgb4vf: Use defined Mailbox Timeout
Date: Mon, 14 Feb 2011 14:56:25 -0800
Message-ID: <1297724185-27452-5-git-send-email-leedom@chelsio.com>
References: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5094 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab1BNW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:56:29 -0500
In-Reply-To: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF Driver should use mailbox command timeout specified in t4fw_interface.h
rather than hard-coded value of 500ms.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/t4vf_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index 0f51c80..192db22 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -171,7 +171,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	delay_idx = 0;
 	ms = delay[0];
 
-	for (i = 0; i < 500; i += ms) {
+	for (i = 0; i < FW_CMD_MAX_TIMEOUT; i += ms) {
 		if (sleep_ok) {
 			ms = delay[delay_idx];
 			if (delay_idx < ARRAY_SIZE(delay) - 1)
-- 
1.7.0.4

