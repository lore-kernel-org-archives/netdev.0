From: Florian Westphal <fw@strlen.de>
Subject: [PATCH iproute2] utils: relax strtoX checking in get_time_rtt
Date: Tue, 11 Nov 2014 01:38:21 +0100
Message-ID: <1415666301-24900-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33350 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbaKKAiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 19:38:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip route change dev tap0 192.168.7.0/24 rto_min 1ms
Error: argument "1ms" is wrong: "rto_min" value is invalid

get_time_rtt() checks for 's' or 'msec' and converts to milliseconds
if needed.

Fixes: 697ac63905 (utils: fix range checking for get_u32/get_u64 et all)
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 lib/utils.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index dc21567..987377b 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -144,8 +144,8 @@ int get_time_rtt(unsigned *val, const char *arg, int *raw)
 		if (t < 0.0)
 			return -1;
 
-		/* extra non-digits */
-		if (!p || p == arg || *p)
+		/* no digits? */
+		if (!p || p == arg)
 			return -1;
 
 		/* over/underflow */
@@ -154,8 +154,8 @@ int get_time_rtt(unsigned *val, const char *arg, int *raw)
 	} else {
 		res = strtoul(arg, &p, 0);
 
-		/* empty string or trailing non-digits */
-		if (!p || p == arg || *p)
+		/* empty string? */
+		if (!p || p == arg)
 			return -1;
 
 		/* overflow */
-- 
2.0.4
