From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] af_key: suppress a warning for 64k pages.
Date: Wed, 31 Oct 2007 16:24:52 +1100
Message-ID: <20071031162452.fcea4431.sfr@canb.auug.org.au>
References: <20071031145954.fe106f73.sfr@canb.auug.org.au>
	<20071030.210846.215166155.davem@davemloft.net>
	<20071031153422.44f864e8.sfr@canb.auug.org.au>
	<20071030.214219.256397507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:48853 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbXJaFY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 01:24:59 -0400
In-Reply-To: <20071030.214219.256397507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On PowerPC allmodconfig build we get this:

net/key/af_key.c:400: warning: comparison is always false due to limited range of data type

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/key/af_key.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

This version gets rid of the warning without the ugliness of ifdefs.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7969f8a..266f112 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -395,9 +395,9 @@ static inline int pfkey_sec_ctx_len(struct sadb_x_sec_ctx *sec_ctx)
 static inline int verify_sec_ctx_len(void *p)
 {
 	struct sadb_x_sec_ctx *sec_ctx = (struct sadb_x_sec_ctx *)p;
-	int len;
+	int len = sec_ctx->sadb_x_ctx_len;
 
-	if (sec_ctx->sadb_x_ctx_len > PAGE_SIZE)
+	if (len > PAGE_SIZE)
 		return -EINVAL;
 
 	len = pfkey_sec_ctx_len(sec_ctx);
-- 
1.5.3.4

