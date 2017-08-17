From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 7/7] lib/ll_map: Make sure im->name is NULL-terminated
Date: Thu, 17 Aug 2017 19:09:32 +0200
Message-ID: <20170817170932.24659-8-phil@nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43619 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753428AbdHQRM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:58 -0400
In-Reply-To: <20170817170932.24659-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/ll_map.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/ll_map.c b/lib/ll_map.c
index 4e4556c9ac80b..4d06eb69f138a 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -120,11 +120,11 @@ int ll_remember_index(const struct sockaddr_nl *who,
 		return 0;
 	}
 
-	im = malloc(sizeof(*im));
+	im = calloc(1, sizeof(*im));
 	if (im == NULL)
 		return 0;
 	im->index = ifi->ifi_index;
-	strcpy(im->name, ifname);
+	strncpy(im->name, ifname, IFNAMSIZ - 1);
 	im->type = ifi->ifi_type;
 	im->flags = ifi->ifi_flags;
 
-- 
2.13.1
