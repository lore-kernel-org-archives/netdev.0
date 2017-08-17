From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/7] ipntable: Make sure filter.name is NULL-terminated
Date: Thu, 17 Aug 2017 19:09:26 +0200
Message-ID: <20170817170932.24659-2-phil@nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49477 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751665AbdHQRLR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:11:17 -0400
In-Reply-To: <20170817170932.24659-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 879626ee4f491..7be1f04d33d90 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -633,7 +633,8 @@ static int ipntable_show(int argc, char **argv)
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
 
-			strncpy(filter.name, *argv, sizeof(filter.name));
+			strncpy(filter.name, *argv, sizeof(filter.name) - 1);
+			filter.name[sizeof(filter.name) - 1] = '\0';
 		} else
 			invarg("unknown", *argv);
 
-- 
2.13.1
