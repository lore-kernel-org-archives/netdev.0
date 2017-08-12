From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 30/51] ss: Skip useless check in parse_hostcond()
Date: Sat, 12 Aug 2017 14:04:49 +0200
Message-ID: <20170812120510.28750-31-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38667 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752181AbdHLMIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:25 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The passed 'addr' parameter is dereferenced by caller before and in
parse_hostcond() multiple times before this check, so assume it is
always true.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index b4f89c85c2d52..5ea388fbf1c1a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1671,7 +1671,7 @@ void *parse_hostcond(char *addr, bool is_port)
 			}
 		}
 	}
-	if (!is_port && addr && *addr && *addr != '*') {
+	if (!is_port && *addr && *addr != '*') {
 		if (get_prefix_1(&a.addr, addr, fam)) {
 			if (get_dns_host(&a, addr, fam)) {
 				fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", addr);
-- 
2.13.1
