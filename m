From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 23/51] ifstat: Fix memleak in error case
Date: Sat, 12 Aug 2017 14:04:42 +0200
Message-ID: <20170812120510.28750-24-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36749 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752293AbdHLMHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:03 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index a853ee6d7e3b3..8fa354265a9a1 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -143,8 +143,10 @@ static int get_nlmsg_extended(const struct sockaddr_nl *who,
 		struct rtattr *attr;
 
 		attr = parse_rtattr_one_nested(sub_type, tb[filter_type]);
-		if (attr == NULL)
+		if (attr == NULL) {
+			free(n);
 			return 0;
+		}
 		memcpy(&n->val, RTA_DATA(attr), sizeof(n->val));
 	}
 	memset(&n->rate, 0, sizeof(n->rate));
-- 
2.13.1
