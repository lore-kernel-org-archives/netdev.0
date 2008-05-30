From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 06/13 net-next-2.6] [TIPC]: Prevent access of non-existent field in short message header
Date: Fri, 30 May 2008 14:20:41 -0400
Message-ID: <1212171648-27122-7-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50515 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071AbYE3SXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:08 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates a case where TIPC's link code could try reading
a field that is not present in a short message header.  (The random
value obtained was not being used, but the read operation could result
in an invalid memory access exception in extremely rare circumstances.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/link.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c62ebfe..022cb2f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2674,10 +2674,12 @@ int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 	u32 pack_sz = link_max_pkt(l_ptr);
 	u32 fragm_sz = pack_sz - INT_H_SIZE;
 	u32 fragm_no = 1;
-	u32 destaddr = msg_destnode(inmsg);
+	u32 destaddr;
 
 	if (msg_short(inmsg))
 		destaddr = l_ptr->addr;
+	else
+		destaddr = msg_destnode(inmsg);
 
 	if (msg_routed(inmsg))
 		msg_set_prevnode(inmsg, tipc_own_addr);
-- 
1.5.3.2

