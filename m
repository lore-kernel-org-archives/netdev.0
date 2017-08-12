From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 43/51] tc/tc_filter: Make sure filter name is not empty
Date: Sat, 12 Aug 2017 14:05:02 +0200
Message-ID: <20170812120510.28750-44-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51757 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752243AbdHLMJx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:53 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The later check for 'k[0] != 0' requires a non-empty filter name,
otherwise NULL pointer dereference in 'q' might happen.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/tc_filter.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index b13fb9185d4fd..a799edb35886d 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
 			usage();
 			return 0;
 		} else {
+			if (!strlen(*argv))
+				invarg("invalid filter name", *argv);
+
 			strncpy(k, *argv, sizeof(k)-1);
 
 			q = get_filter_kind(k);
-- 
2.13.1
