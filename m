From: Igor Pylypiv <igor.pylypiv@gmail.com>
Subject: [PATCH] net: fix description of skb_find_text() according to removed functionality
Date: Tue,  7 Feb 2017 18:45:37 -0800
Message-ID: <1486521937-10638-1-git-send-email-igor.pylypiv@gmail.com>
References: <20170207.105320.45609559819874123.davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
To: "David S . Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33816 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751698AbdBHCrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 21:47:47 -0500
In-Reply-To: <20170207.105320.45609559819874123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Textsearch state parameter was moved to local scope of the function.
This eliminates usage of textsearch_next() to find subsequent occurrences.

Fixes: 59a2440fd3cf ("net: Remove state argument from skb_find_text()")
Signed-off-by: Igor Pylypiv <igor.pylypiv@gmail.com>
---
 net/core/skbuff.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9ccba86..90366c5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2919,9 +2919,8 @@ static void skb_ts_finish(struct ts_config *conf, struct ts_state *state)
  * @config: textsearch configuration
  *
  * Finds a pattern in the skb data according to the specified
- * textsearch configuration. Use textsearch_next() to retrieve
- * subsequent occurrences of the pattern. Returns the offset
- * to the first occurrence or UINT_MAX if no match was found.
+ * textsearch configuration. Returns the offset to the first
+ * occurrence or UINT_MAX if no match was found.
  */
 unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 			   unsigned int to, struct ts_config *config)
