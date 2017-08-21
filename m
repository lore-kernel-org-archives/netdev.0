From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/3] iproute: Check mark value input
Date: Mon, 21 Aug 2017 18:36:50 +0200
Message-ID: <20170821163652.23752-2-phil@nwl.cc>
References: <20170821163652.23752-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49845 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753726AbdHUQhR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 12:37:17 -0400
In-Reply-To: <20170821163652.23752-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Drop newline from end of error message, invarg() already does that.
---
 ip/iproute.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index cb695ad4141a7..5936e2a978bc7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1493,7 +1493,8 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 			id = *argv;
 		} else if (strcmp(*argv, "mark") == 0) {
 			NEXT_ARG();
-			get_unsigned(&mark, *argv, 0);
+			if (get_unsigned(&mark, *argv, 0))
+				invarg("invalid mark value", *argv);
 			filter.markmask = -1;
 		} else if (strcmp(*argv, "via") == 0) {
 			int family;
@@ -1710,7 +1711,8 @@ static int iproute_get(int argc, char **argv)
 			idev = *argv;
 		} else if (matches(*argv, "mark") == 0) {
 			NEXT_ARG();
-			get_unsigned(&mark, *argv, 0);
+			if (get_unsigned(&mark, *argv, 0))
+				invarg("invalid mark value", *argv);
 		} else if (matches(*argv, "oif") == 0 ||
 			   strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-- 
2.13.1
