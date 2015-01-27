From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: don't OOPS on socket aio
Date: Tue, 27 Jan 2015 12:26:24 -0800 (PST)
Message-ID: <20150127.122624.2124938550888384076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbbA0U0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:26:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Christoph Hellwig <hch@lst.de>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/socket.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a2c33a4..418795c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -869,9 +869,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
 					 struct sock_iocb *siocb)
 {
-	if (!is_sync_kiocb(iocb))
-		BUG();
-
 	siocb->kiocb = iocb;
 	iocb->private = siocb;
 	return siocb;
-- 
1.7.11.7
