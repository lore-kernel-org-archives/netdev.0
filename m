From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] rds: signedness bug
Date: Sun, 19 Sep 2010 01:42:25 +0200
Message-ID: <20100918234224.GC6236@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35659 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab0IRXmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 19:42:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original code if the copy_from_user() fails in rds_rdma_pages()
then the error handling fails and we get a stack trace from kmalloc().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 4806467..1a41deb 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -522,7 +522,7 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	struct rds_rdma_args *args;
 	struct rds_iovec vec;
 	struct rm_rdma_op *op = &rm->rdma;
-	unsigned int nr_pages;
+	int nr_pages;
 	unsigned int nr_bytes;
 	struct page **pages = NULL;
 	struct rds_iovec __user *local_vec;
