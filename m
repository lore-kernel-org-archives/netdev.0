From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 7/7] lib/ll_map: Choose size of new cache items at run-time
Date: Mon, 21 Aug 2017 15:23:41 +0200
Message-ID: <20170821132341.23118-8-phil@nwl.cc>
References: <20170821132341.23118-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55639 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753264AbdHUNXx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 09:23:53 -0400
In-Reply-To: <20170821132341.23118-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having a fixed buffer of 16 bytes for the interface name,
tailor size of new ll_cache entry using the interface name's actual
length. This also makes sure the following call to strcpy() is safe.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/ll_map.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/ll_map.c b/lib/ll_map.c
index 4e4556c9ac80b..70684b02042b6 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -30,7 +30,7 @@ struct ll_cache {
 	unsigned	flags;
 	unsigned 	index;
 	unsigned short	type;
-	char		name[IFNAMSIZ];
+	char		name[];
 };
 
 #define IDXMAP_SIZE	1024
@@ -120,7 +120,7 @@ int ll_remember_index(const struct sockaddr_nl *who,
 		return 0;
 	}
 
-	im = malloc(sizeof(*im));
+	im = malloc(sizeof(*im) + strlen(ifname) + 1);
 	if (im == NULL)
 		return 0;
 	im->index = ifi->ifi_index;
-- 
2.13.1
