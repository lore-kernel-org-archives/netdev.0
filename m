From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 9/32] [TIPC] Fix for NULL pointer dereference
Date: Thu, 22 Jun 2006 15:59:22 +0200
Message-ID: <1150984785979-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org, Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:27030 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030642AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Sesterhenn <snakebyte@gmx.de>

This fixes a bug spotted by the coverity checker, bug id #366. If
(mod(seqno - prev) != 1) we set buf to NULL, dereference it in the for
case, and set it to whatever value happes to be at adress 0+next, if it
happens to be non-zero, we even stay in the loop. It seems that the author
intended to break there.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/bcast.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 00691b7..44645f5 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -349,8 +349,10 @@ static void tipc_bclink_peek_nack(u32 de
 		for (; buf; buf = buf->next) {
 			u32 seqno = buf_seqno(buf);
 
-			if (mod(seqno - prev) != 1)
+			if (mod(seqno - prev) != 1) {
 				buf = NULL;
+				break;
+			}
 			if (seqno == gap_after)
 				break;
 			prev = seqno;
-- 
1.4.0

