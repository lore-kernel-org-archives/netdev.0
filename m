From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 11/51] iproute: Check mark value input
Date: Sat, 12 Aug 2017 14:04:30 +0200
Message-ID: <20170812120510.28750-12-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58707 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752174AbdHLMG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:57 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 89caac124f489..5fe8a3a75d5b7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1495,7 +1495,8 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 			id = *argv;
 		} else if (strcmp(*argv, "mark") == 0) {
 			NEXT_ARG();
-			get_unsigned(&mark, *argv, 0);
+			if (get_unsigned(&mark, *argv, 0))
+				invarg("invalid mark value\n", *argv);
 			filter.markmask = -1;
 		} else if (strcmp(*argv, "via") == 0) {
 			int family;
@@ -1712,7 +1713,8 @@ static int iproute_get(int argc, char **argv)
 			idev = *argv;
 		} else if (matches(*argv, "mark") == 0) {
 			NEXT_ARG();
-			get_unsigned(&mark, *argv, 0);
+			if (get_unsigned(&mark, *argv, 0))
+				invarg("invalid mark value\n", *argv);
 		} else if (matches(*argv, "oif") == 0 ||
 			   strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-- 
2.13.1
