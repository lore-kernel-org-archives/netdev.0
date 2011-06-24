From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/20] tipc: Add sanity check to detect rejection of non-payload messages
Date: Fri, 24 Jun 2011 18:07:11 -0400
Message-ID: <1308953247-25266-5-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34356 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014Ab1FXWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:43 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Introduces an internal sanity check to ensure that the only undeliverable
messages TIPC attempts to return to their origin are application payload
messages.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 3946b5b..756e64c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -367,6 +367,12 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		imp++;
 
 	/* discard rejected message if it shouldn't be returned to sender */
+
+	if (WARN(!msg_isdata(msg),
+		 "attempt to reject message with user=%u", msg_user(msg))) {
+		dump_stack();
+		goto exit;
+	}
 	if (msg_errcode(msg) || msg_dest_droppable(msg))
 		goto exit;
 
-- 
1.7.4.4

