From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 09/51] ipntable: Make sure filter.name is NULL-terminated
Date: Sat, 12 Aug 2017 14:04:28 +0200
Message-ID: <20170812120510.28750-10-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54229 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752075AbdHLMHf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:35 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 1837909fa42e7..30907146e85a3 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -631,7 +631,8 @@ static int ipntable_show(int argc, char **argv)
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
 
-			strncpy(filter.name, *argv, sizeof(filter.name));
+			strncpy(filter.name, *argv, sizeof(filter.name) - 1);
+			filter.name[sizeof(filter.name) - 1] = '\0';
 		} else
 			invarg("unknown", *argv);
 
-- 
2.13.1
