From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/21] tipc: Don't initialize link selector field in fragmented messages
Date: Tue, 10 May 2011 16:44:22 -0400
Message-ID: <1305060277-15600-7-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52323 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab1EJUpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:00 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates code that sets the link selector field in the header of
fragmented messages, since this information is never referenced.
(The unnecessary initialization was harmless as it was over-written
by the fragmented message identifier value before the fragments were
transmitted.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index ebf338f..95249ba 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1169,7 +1169,6 @@ again:
 
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, msg_destnode(hdr));
-	msg_set_link_selector(&fragm_hdr, sender->ref);
 	msg_set_size(&fragm_hdr, max_pkt);
 	msg_set_fragm_no(&fragm_hdr, 1);
 
@@ -2427,7 +2426,6 @@ static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, destaddr);
-	msg_set_link_selector(&fragm_hdr, msg_link_selector(inmsg));
 	msg_set_long_msgno(&fragm_hdr, mod(l_ptr->long_msg_seq_no++));
 	msg_set_fragm_no(&fragm_hdr, fragm_no);
 	l_ptr->stats.sent_fragmented++;
-- 
1.7.4.4

