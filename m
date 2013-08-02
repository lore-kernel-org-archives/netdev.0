From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: netlink: minor: remove unused pointer in alloc_pg_vec
Date: Fri,  2 Aug 2013 17:32:39 +0200
Message-ID: <1375457559-7565-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab3HBPcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 11:32:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Variable ptr is being assigned, but never used, so just remove it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/netlink/af_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0c61b59..6273772 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -294,14 +294,14 @@ static void **alloc_pg_vec(struct netlink_sock *nlk,
 {
 	unsigned int block_nr = req->nm_block_nr;
 	unsigned int i;
-	void **pg_vec, *ptr;
+	void **pg_vec;
 
 	pg_vec = kcalloc(block_nr, sizeof(void *), GFP_KERNEL);
 	if (pg_vec == NULL)
 		return NULL;
 
 	for (i = 0; i < block_nr; i++) {
-		pg_vec[i] = ptr = alloc_one_pg_vec_page(order);
+		pg_vec[i] = alloc_one_pg_vec_page(order);
 		if (pg_vec[i] == NULL)
 			goto err1;
 	}
-- 
1.7.11.7
