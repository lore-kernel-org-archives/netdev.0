From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/17] tipc: nuke the delimit static inline function.
Date: Wed, 29 Feb 2012 18:18:32 -0500
Message-ID: <1330557523-2024-7-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53952 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965160Ab2B2XTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:01 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This "shortform" is actually longer than typing out what it is really
trying to do, and just makes reading the code more difficult, so
lets simply shoot it in the head.

In the case of log.c - the comparison is on a u32, so we can drop the
check for < 0 at the same time.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |    8 ++++----
 net/tipc/core.h   |   10 ----------
 net/tipc/log.c    |    2 +-
 3 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 9fefd32..69cca4f 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -218,7 +218,7 @@ static struct sk_buff *cfg_set_max_publications(void)
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != delimit(value, 1, 65535))
+	if (value < 1 || value > 65535)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max publications must be 1-65535)");
 	tipc_max_publications = value;
@@ -233,7 +233,7 @@ static struct sk_buff *cfg_set_max_subscriptions(void)
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != delimit(value, 1, 65535))
+	if (value < 1 || value > 65535)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max subscriptions must be 1-65535");
 	tipc_max_subscriptions = value;
@@ -249,7 +249,7 @@ static struct sk_buff *cfg_set_max_ports(void)
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
 	if (value == tipc_max_ports)
 		return tipc_cfg_reply_none();
-	if (value != delimit(value, 127, 65535))
+	if (value < 127 || value > 65535)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max ports must be 127-65535)");
 	if (tipc_mode != TIPC_NOT_RUNNING)
@@ -268,7 +268,7 @@ static struct sk_buff *cfg_set_netid(void)
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
 	if (value == tipc_net_id)
 		return tipc_cfg_reply_none();
-	if (value != delimit(value, 1, 9999))
+	if (value < 1 || value > 9999)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network id must be 1-9999)");
 	if (tipc_mode == TIPC_NET_MODE)
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 2761af3..1260b05 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -168,16 +168,6 @@ extern void tipc_netlink_stop(void);
 extern int  tipc_socket_init(void);
 extern void tipc_socket_stop(void);
 
-static inline int delimit(int val, int min, int max)
-{
-	if (val > max)
-		return max;
-	if (val < min)
-		return min;
-	return val;
-}
-
-
 /*
  * TIPC timer and signal code
  */
diff --git a/net/tipc/log.c b/net/tipc/log.c
index 952c39f..895c6e5 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -304,7 +304,7 @@ struct sk_buff *tipc_log_resize_cmd(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value != delimit(value, 0, 32768))
+	if (value > 32768)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (log size must be 0-32768)");
 	if (tipc_log_resize(value))
-- 
1.7.9.1
