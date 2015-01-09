From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/3] rhashtable: add a note for grow and shrink decision functions
Date: Fri, 9 Jan 2015 16:23:38 +0800
Message-ID: <1420791818-22150-4-git-send-email-ying.xue@windriver.com>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36887 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbbAIIYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 03:24:10 -0500
In-Reply-To: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As commit c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for
worker queue") moves condition statements of verifying whether hash
table size exceeds its maximum threshold or reaches its minimum
threshold from resizing functions to resizing decision functions,
we should add a note in rhashtable.h to indicate the implementation
of what the grow and shrink decision function must enforce min/max
shift, otherwise, it's failed to take min/max shift's set watermarks
into effect.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 7b9bd77..9570832 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -79,6 +79,10 @@ struct rhashtable;
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
  * @shrink_decision: If defined, may return true if table should shrink
+ *
+ * Note: when implementing the grow and shrink decision function, min/max
+ * shift must be enforced, otherwise, resizing watermarks they set may be
+ * useless.
  */
 struct rhashtable_params {
 	size_t			nelem_hint;
-- 
1.7.9.5
