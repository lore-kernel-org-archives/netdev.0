From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: sunrpc: svcauth_gss: use BUG_ON instead of if condition
 followed by BUG
Date: Mon, 23 Oct 2017 13:16:35 -0500
Message-ID: <20171023181635.GA25334@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.148.204]:11007 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751388AbdJWSQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:16:36 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id ABB7635F65
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 13:16:36 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 7b1ee5a..a10ce43 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -855,11 +855,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct g
 		return stat;
 	if (integ_len > buf->len)
 		return stat;
-	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
-		BUG();
+	BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, integ_len));
 	/* copy out mic... */
-	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
-		BUG();
+	BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic.len));
 	if (mic.len > RPC_MAX_AUTH_SIZE)
 		return stat;
 	mic.data = kmalloc(mic.len, GFP_KERNEL);
@@ -1611,8 +1609,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 	BUG_ON(integ_len % 4);
 	*p++ = htonl(integ_len);
 	*p++ = htonl(gc->gc_seq);
-	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
-		BUG();
+	BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len));
 	if (resbuf->tail[0].iov_base == NULL) {
 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
 			goto out_err;
-- 
2.7.4
