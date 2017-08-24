From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 3/4] tc/tc_filter: Make sure filter name is not empty
Date: Thu, 24 Aug 2017 11:46:33 +0200
Message-ID: <20170824094634.4093-4-phil@nwl.cc>
References: <20170824094634.4093-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42583 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752435AbdHXJq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:46:59 -0400
In-Reply-To: <20170824094634.4093-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The later check for 'k[0] != 0' requires a non-empty filter name,
otherwise NULL pointer dereference in 'q' might happen.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Instead of calling strlen(), just make sure **argv is not 0.
---
 tc/tc_filter.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index b13fb9185d4fd..cf290ae8e252c 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 			usage();
 			return 0;
 		} else {
+			if (!**argv)
+				invarg("invalid filter name", *argv);
+
 			strncpy(k, *argv, sizeof(k)-1);
 
 			q = get_filter_kind(k);
-- 
2.13.1
