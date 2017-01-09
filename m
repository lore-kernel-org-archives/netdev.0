From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/7] net: ipv4: Save trie prefix to fib lookup result
Date: Mon,  9 Jan 2017 13:32:49 -0800
Message-ID: <1483997571-3964-6-git-send-email-dsa@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35399 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941409AbdAIVdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:33:01 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so24368435pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:33:00 -0800 (PST)
In-Reply-To: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix is needed for returning matching route spec on get route request.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip_fib.h | 1 +
 net/ipv4/fib_trie.c  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 57c2a863d0b2..f2cc345852d7 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -136,6 +136,7 @@ struct fib_rule;
 
 struct fib_table;
 struct fib_result {
+	__be32		prefix;
 	unsigned char	prefixlen;
 	unsigned char	nh_sel;
 	unsigned char	type;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2919d1a10cfd..2fc5793cce36 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1544,6 +1544,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
 				atomic_inc(&fi->fib_clntref);
 
+			res->prefix = htonl(n->key);
 			res->prefixlen = KEYLENGTH - fa->fa_slen;
 			res->nh_sel = nhsel;
 			res->type = fa->fa_type;
-- 
2.1.4
