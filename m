From: Dan Carpenter <error27@gmail.com>
Subject: [patch] 9p: fix return value of rdma_request()
Date: Thu, 11 Feb 2010 11:20:45 +0300
Message-ID: <20100211082044.GE14210@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Abhishek Kulkarni <adkulkar@umail.iu.edu>,
	Venkateswararao Jujjuri <jvrao@us.ibm.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56629 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab0BKIVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 03:21:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rdma_request() is supposed to return negative values on error.  This change
means that if a kmalloc() fails it returns -ENOMEM.  The original code returned
certain negative values, zero on success and zero on kmalloc() failures.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I was just reading the code and I noticed this bug.  I haven't tested it because I
don't have the hardware.

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 2c95a89..589e340 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -419,7 +419,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	struct p9_trans_rdma *rdma = client->trans;
 	struct ib_send_wr wr, *bad_wr;
 	struct ib_sge sge;
-	int err = 0;
+	int err = -ENOMEM;
 	unsigned long flags;
 	struct p9_rdma_context *c = NULL;
 	struct p9_rdma_context *rpl_context = NULL;
