From: Milton Miller <miltonm@bga.com>
Subject: [PATCH] tcp: correct kcalloc usage
Date: Thu, 10 Jul 2008 16:25:33 -0500 (CDT)
Message-ID: <for-27-patch8-2@bga.com>
References: <for-27-patch8-1@bga.com>
Cc: linux-kernel@vger.org, Andrew Morton <akpm@linux-foundation.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sullivan.realtime.net ([205.238.132.226]:1242 "EHLO
	sullivan.realtime.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbYGJVjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:39:52 -0400
In-Reply-To: <for-27-patch8-1@bga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kcalloc is supposed to be called with the count as its first argument and
the element size as the second.

Signed-off-by: Milton Miller <miltonm@bga.com>
---
Both arguments are size_t so does not affect correctness.  This
callsite is during module_init and therefore not performance critical.
Another patch will optimize the case when the count is variable but
the size is fixed.

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 5ff0ce6..7ddc30f 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -224,7 +224,7 @@ static __init int tcpprobe_init(void)
 	if (bufsize < 0)
 		return -EINVAL;
 
-	tcp_probe.log = kcalloc(sizeof(struct tcp_log), bufsize, GFP_KERNEL);
+	tcp_probe.log = kcalloc(bufsize, sizeof(struct tcp_log), GFP_KERNEL);
 	if (!tcp_probe.log)
 		goto err0;
 
