From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] af_key: suppress a warning for 64k pages.
Date: Wed, 31 Oct 2007 14:59:54 +1100
Message-ID: <20071031145954.fe106f73.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:57621 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960AbXJaD7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 23:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On PowerPC allmodconfig build we get this:

net/key/af_key.c:400: warning: comparison is always false due to limited range of data type

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/key/af_key.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7969f8a..7da6c1a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -397,8 +397,11 @@ static inline int verify_sec_ctx_len(void *p)
 	struct sadb_x_sec_ctx *sec_ctx = (struct sadb_x_sec_ctx *)p;
 	int len;
 
+	/* sadb_x_ctx_len is uint16_t */
+#if PAGE_SIZE < (1 << 16)
 	if (sec_ctx->sadb_x_ctx_len > PAGE_SIZE)
 		return -EINVAL;
+#endif
 
 	len = pfkey_sec_ctx_len(sec_ctx);
 
-- 
1.5.3.4

