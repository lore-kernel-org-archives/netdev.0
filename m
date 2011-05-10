From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/21] tipc: Avoid pointless masking of fragmented message identifier
Date: Tue, 10 May 2011 16:44:23 -0400
Message-ID: <1305060277-15600-8-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52345 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab1EJUpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:01 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates code that restricts a link's counter of its fragmented
messages to a 16-bit value, since the counter value is automatically
restricted to this range when it is written into the message header.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 95249ba..ad356df 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1276,7 +1276,7 @@ reject:
 	/* Append whole chain to send queue: */
 
 	buf = buf_chain;
-	l_ptr->long_msg_seq_no = mod(l_ptr->long_msg_seq_no + 1);
+	l_ptr->long_msg_seq_no++;
 	if (!l_ptr->next_out)
 		l_ptr->next_out = buf_chain;
 	l_ptr->stats.sent_fragmented++;
@@ -2426,7 +2426,7 @@ static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, destaddr);
-	msg_set_long_msgno(&fragm_hdr, mod(l_ptr->long_msg_seq_no++));
+	msg_set_long_msgno(&fragm_hdr, l_ptr->long_msg_seq_no++);
 	msg_set_fragm_no(&fragm_hdr, fragm_no);
 	l_ptr->stats.sent_fragmented++;
 
-- 
1.7.4.4

