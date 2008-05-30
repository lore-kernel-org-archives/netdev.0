From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 03/13 net-next-2.6] [TIPC]: Fix bugs in message error code display when debugging
Date: Fri, 30 May 2008 14:20:38 -0400
Message-ID: <1212171648-27122-4-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50503 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbYE3SXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:07 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects two problems in the display of error code
information in TIPC messages when debugging:
- no longer tries to display error code in NAME_DISTRIBUTOR
  messages, which don't have the error field
- now displays error code in 24 byte data messages, which do
  have the error field

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/msg.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 38abeba..73dcd00 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -230,13 +230,10 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 
 	switch (usr) {
 	case CONN_MANAGER:
-	case NAME_DISTRIBUTOR:
 	case TIPC_LOW_IMPORTANCE:
 	case TIPC_MEDIUM_IMPORTANCE:
 	case TIPC_HIGH_IMPORTANCE:
 	case TIPC_CRITICAL_IMPORTANCE:
-		if (msg_short(msg))
-			break;	/* No error */
 		switch (msg_errcode(msg)) {
 		case TIPC_OK:
 			break;
-- 
1.5.3.2

