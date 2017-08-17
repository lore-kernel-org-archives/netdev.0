From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 4/7] ipmaddr: Avoid accessing uninitialized data
Date: Thu, 17 Aug 2017 19:09:28 +0200
Message-ID: <20170817170931.24302-5-phil@nwl.cc>
References: <20170817170931.24302-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54429 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753326AbdHQRNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:13:16 -0400
In-Reply-To: <20170817170931.24302-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like this can only happen if /proc/net/igmp is malformed, but
better be sure.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipmaddr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 4f726fdd976f1..85a69e779563d 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -136,7 +136,7 @@ static void read_igmp(struct ma_info **result_p)
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		struct ma_info *ma;
-		size_t len;
+		size_t len = 0;
 
 		if (buf[0] != '\t') {
 			sscanf(buf, "%d%s", &m.index, m.name);
-- 
2.13.1
