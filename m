From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] tcp: syncookies: mark cookie_secret read_mostly
Date: Tue, 26 Aug 2014 12:55:53 +0200
Message-ID: <1409050553-21945-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60773 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754359AbaHZK4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 06:56:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

only written once.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/syncookies.c | 2 +-
 net/ipv6/syncookies.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index c0c7568..0431a8f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -25,7 +25,7 @@
 
 extern int sysctl_tcp_syncookies;
 
-static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
+static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 83cea1d..c643dc9 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -24,7 +24,7 @@
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
-static u32 syncookie6_secret[2][16-4+SHA_DIGEST_WORDS];
+static u32 syncookie6_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 
 /* RFC 2460, Section 8.3:
  * [ipv6 tcp] MSS must be computed as the maximum packet size minus 60 [..]
-- 
1.8.1.5
