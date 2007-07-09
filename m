From: akpm@linux-foundation.org
Subject: [patch 3/8] "wrong timeout value in sk_wait_data()": cleanups
Date: Mon, 09 Jul 2007 11:51:10 -0700
Message-ID: <200707091851.l69IpBFV001731@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, vvs@sw.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35176 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759908AbXGISwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

- save 4 bytes

- it's read-mostly.

Cc: "David S. Miller" <davem@davemloft.net>
Acked-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN net/core/sock.c~wrong-timeout-value-in-sk_wait_data-v2-fix net/core/sock.c
--- a/net/core/sock.c~wrong-timeout-value-in-sk_wait_data-v2-fix
+++ a/net/core/sock.c
@@ -210,7 +210,8 @@ static int sock_set_timeout(long *timeo_
 		return -EDOM;
 
 	if (tv.tv_sec < 0) {
-		static int warned = 0;
+		static int warned __read_mostly;
+
 		*timeo_p = 0;
 		if (warned < 10 && net_ratelimit())
 			warned++;
_
