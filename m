From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rds: fix a leak of kernel memory
Date: Mon, 16 Aug 2010 15:25:00 +0200
Message-ID: <1281965100.2524.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:51440 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab0HPNZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 09:25:05 -0400
Received: by ewy23 with SMTP id 23so2281091ewy.19
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 06:25:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct rds_rdma_notify contains a 32 bits hole on 64bit arches,
make sure it is zeroed before copying it to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andy Grover <andy.grover@oracle.com>
---
 net/rds/recv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/recv.c b/net/rds/recv.c
index 795a00b..c93588c 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -297,7 +297,7 @@ static int rds_still_queued(struct rds_sock *rs, struct rds_incoming *inc,
 int rds_notify_queue_get(struct rds_sock *rs, struct msghdr *msghdr)
 {
 	struct rds_notifier *notifier;
-	struct rds_rdma_notify cmsg;
+	struct rds_rdma_notify cmsg = { 0 }; /* fill holes with zero */
 	unsigned int count = 0, max_messages = ~0U;
 	unsigned long flags;
 	LIST_HEAD(copy);


