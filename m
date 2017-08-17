From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 5/7] ss: Skip useless check in parse_hostcond()
Date: Thu, 17 Aug 2017 19:09:29 +0200
Message-ID: <20170817170931.24089-6-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57507 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753165AbdHQRLm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:11:42 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
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
index f0d1c22f75cff..2debccce5260b 100644
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
