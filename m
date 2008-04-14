From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/7 net-2.6.26] [TIPC]: Ignore message padding when receiving stream data
Date: Mon, 14 Apr 2008 17:16:30 -0400
Message-ID: <1208207794-2229-4-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55770 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762639AbYDNVSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:24 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that padding bytes appearing at the end of
an incoming TIPC message are not returned as valid stream data.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c1a199c..ead22e5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1027,7 +1027,7 @@ restart:
 
 	if (!err) {
 		buf_crs = (unsigned char *)(TIPC_SKB_CB(buf)->handle);
-		sz = skb_tail_pointer(buf) - buf_crs;
+		sz = (unsigned char *)msg + msg_size(msg) - buf_crs;
 
 		needed = (buf_len - sz_copied);
 		sz_to_copy = (sz <= needed) ? sz : needed;
-- 
1.5.3.2

