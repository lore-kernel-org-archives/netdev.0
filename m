From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/8] net: ipv4: Save trie prefix to fib lookup result
Date: Thu, 25 May 2017 10:42:37 -0700
Message-ID: <1495734160-47659-6-git-send-email-roopa@cumulusnetworks.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net, dsahern@gmail.com, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33213 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969990AbdEYRnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:43:08 -0400
Received: by mail-pf0-f179.google.com with SMTP id e193so173726780pfh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 10:43:08 -0700 (PDT)
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>

Prefix is needed for returning matching route spec on get route request.

Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/ip_fib.h | 1 +
 net/ipv4/fib_trie.c  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 42e8b8f..25f5c51 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -136,6 +136,7 @@ struct fib_info {
 
 struct fib_table;
 struct fib_result {
+	__be32		prefix;
 	unsigned char	prefixlen;
 	unsigned char	nh_sel;
 	unsigned char	type;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6d0f6c79..6e9df7d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1452,6 +1452,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
 				atomic_inc(&fi->fib_clntref);
 
+			res->prefix = htonl(n->key);
 			res->prefixlen = KEYLENGTH - fa->fa_slen;
 			res->nh_sel = nhsel;
 			res->type = fa->fa_type;
-- 
1.9.1
