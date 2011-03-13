From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 22/26] tipc: Don't respond to neighbor discovery request on blocked bearer
Date: Sun, 13 Mar 2011 17:34:10 -0400
Message-ID: <1300052054-7531-23-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49938 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab1CMVe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:59 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Adds a check to prevent TIPC from trying to respond to an incoming
LINK_CONFIG request message if the associated bearer is currently
prohibited from sending messages.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 2c14d6d..491eff5 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -202,7 +202,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	/* Accept discovery message & send response, if necessary */
 	link_fully_up = link_working_working(link);
 
-	if ((type == DSC_REQ_MSG) && !link_fully_up) {
+	if ((type == DSC_REQ_MSG) && !link_fully_up && !b_ptr->blocked) {
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
 		if (rbuf) {
 			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
-- 
1.7.3.3

