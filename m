From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] tcp: syncookies: reduce mss table to four values
Date: Sun, 25 Aug 2013 19:54:02 +0200
Message-ID: <1377453242-4773-2-git-send-email-fw@strlen.de>
References: <1377453242-4773-1-git-send-email-fw@strlen.de>
Cc: jbohac@suse.cz, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56429 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755215Ab3HYRzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 13:55:35 -0400
In-Reply-To: <1377453242-4773-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Halve mss table size to make blind cookie guessing more difficult.
This is sad since the tables were already small, but there
is little alternative except perhaps adding more precise mss information
in the tcp timestamp.  Timestamps are unfortunately not ubiquitous.

Guessing all possible cookie values still has 8-in 2**32 chance.

Reported-by: Jakob Lell <jakob@jakoblell.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Another argument AGAINST this patch is that if 16-in 2**32 is
 too easy then 8-in-2**32 will be doable, too.

 net/ipv4/syncookies.c | 6 +-----
 net/ipv6/syncookies.c | 4 ----
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index e2f84eb..fd52401 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -143,14 +143,10 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
  * Table must be sorted.
  */
 static __u16 const msstab[] = {
-	64,
-	512,
 	536,
-	1024,
+	1200,
 	1440,
 	1460,
-	4312,
-	8960,
 };
 
 /*
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6a6d585..cc4513b 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -27,13 +27,9 @@
 
 /* Table must be sorted. */
 static __u16 const msstab[] = {
-	64,
-	512,
-	536,
 	1280 - 60,
 	1480 - 60,
 	1500 - 60,
-	4460 - 60,
 	9000 - 60,
 };
 
-- 
1.8.1.5
