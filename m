From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv4: don't spam dmesg with "Using LC-trie" messages
Date: Sun, 1 May 2011 15:04:11 +0300
Message-ID: <20110501120411.GA5224@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36948 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823Ab1EAMER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 08:04:17 -0400
Received: by bwz15 with SMTP id 15so4026537bwz.19
        for <netdev@vger.kernel.org>; Sun, 01 May 2011 05:04:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_trie_table() is called during netns creation and
Chromium uses clone(CLONE_NEWNET) to sandbox renderer process.

Don't print anything.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/fib_trie.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1978,9 +1978,6 @@ struct fib_table *fib_trie_table(u32 id)
 	t = (struct trie *) tb->tb_data;
 	memset(t, 0, sizeof(*t));
 
-	if (id == RT_TABLE_LOCAL)
-		pr_info("IPv4 FIB: Using LC-trie version %s\n", VERSION);
-
 	return tb;
 }
 
