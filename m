From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net 1/3] bql: Fix POSDIFF() to integer overflow aware.
Date: Thu, 31 May 2012 07:24:39 +0900
Message-ID: <20120531072439.6c634a0b.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38692 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756238Ab2E3WYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 18:24:43 -0400
Received: by pbbrp8 with SMTP id rp8so557612pbb.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 15:24:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

POSDIFF() fails to take into account integer overflow case.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Denys Fedoryshchenko <denys@visp.net.lb>
---
 lib/dynamic_queue_limits.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index 6ab4587..c87eb76 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -10,7 +10,7 @@
 #include <linux/jiffies.h>
 #include <linux/dynamic_queue_limits.h>
 
-#define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
+#define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
 
 /* Records completed count and recalculates the queue limit */
 void dql_completed(struct dql *dql, unsigned int count)
-- 
1.7.3.4
