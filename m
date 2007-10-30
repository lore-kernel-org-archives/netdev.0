From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] rpc_rdma: we need to cast u64 to unsigned long long for
 printing
Date: Tue, 30 Oct 2007 16:12:40 +1100
Message-ID: <20071030161240.bc81cad3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:47793 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbXJ3FMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 01:12:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

as some architectures have unsigned long for u64.

net/sunrpc/xprtrdma/rpc_rdma.c: In function 'rpcrdma_create_chunks':
net/sunrpc/xprtrdma/rpc_rdma.c:222: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
net/sunrpc/xprtrdma/rpc_rdma.c:234: warning: format '%llx' expects type 'long long unsigned int', but argument 5 has type 'u64'
net/sunrpc/xprtrdma/rpc_rdma.c: In function 'rpcrdma_count_chunks':
net/sunrpc/xprtrdma/rpc_rdma.c:577: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'u64

Noticed on PowerPC pseries_defconfig build.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f877b88..9e11ce7 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -221,8 +221,8 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 					seg->mr_base);
 			dprintk("RPC:       %s: read chunk "
 				"elem %d@0x%llx:0x%x pos %d (%s)\n", __func__,
-				seg->mr_len, seg->mr_base, seg->mr_rkey, pos,
-				n < nsegs ? "more" : "last");
+				seg->mr_len, (unsigned long long)seg->mr_base,
+				seg->mr_rkey, pos, n < nsegs ? "more" : "last");
 			cur_rchunk++;
 			r_xprt->rx_stats.read_chunk_count++;
 		} else {		/* write/reply */
@@ -234,8 +234,8 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 			dprintk("RPC:       %s: %s chunk "
 				"elem %d@0x%llx:0x%x (%s)\n", __func__,
 				(type == rpcrdma_replych) ? "reply" : "write",
-				seg->mr_len, seg->mr_base, seg->mr_rkey,
-				n < nsegs ? "more" : "last");
+				seg->mr_len, (unsigned long long)seg->mr_base,
+				seg->mr_rkey, n < nsegs ? "more" : "last");
 			cur_wchunk++;
 			if (type == rpcrdma_replych)
 				r_xprt->rx_stats.reply_chunk_count++;
@@ -577,7 +577,7 @@ rpcrdma_count_chunks(struct rpcrdma_rep *rep, int max, int wrchunk, __be32 **ipt
 			dprintk("RPC:       %s: chunk %d@0x%llx:0x%x\n",
 				__func__,
 				ntohl(seg->rs_length),
-				off,
+				(unsigned long long)off,
 				ntohl(seg->rs_handle));
 		}
 		total_len += ntohl(seg->rs_length);
-- 
1.5.3.4

