From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/3][NETLABEL]: Compilation for CONFIG_AUDIT=n case.
Date: Thu, 07 Feb 2008 20:20:30 +0300
Message-ID: <47AB3DDE.8050109@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52721 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757655AbYBGRU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 12:20:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The audit_log_start() will expand into an empty do { } while (0)
construction and the audit_ctx becomes unused.

The solution: push current->audit_context into audit_log_start()
directly, since it is not required in any other place in the 
calling function.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/netlabel/netlabel_user.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 85a96a3..023fc8f 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -96,7 +96,6 @@ int netlbl_netlink_init(void)
 struct audit_buffer *netlbl_audit_start_common(int type,
 					       struct netlbl_audit *audit_info)
 {
-	struct audit_context *audit_ctx = current->audit_context;
 	struct audit_buffer *audit_buf;
 	char *secctx;
 	u32 secctx_len;
@@ -104,7 +103,7 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 	if (audit_enabled == 0)
 		return NULL;
 
-	audit_buf = audit_log_start(audit_ctx, GFP_ATOMIC, type);
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 		return NULL;
 
-- 
1.5.3.4

