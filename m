From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Use nl_proto_a2n for filtering by netlink proto
Date: Sat,  6 Dec 2014 02:52:19 +0200
Message-ID: <1417827139-10241-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:37633 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLFBCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 20:02:06 -0500
Received: by mail-la0-f46.google.com with SMTP id q1so1557215lam.5
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 17:02:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now it is posible to filter by existing Netlink protos:

    ss -A netlink src uevent
    ss -A netlink src nft
    ss -A netlink src genl

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index a99294d..b9dbfd6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1231,16 +1231,8 @@ void *parse_hostcond(char *addr)
 		}
 		if (addr[0] && strcmp(addr, "*")) {
 			a.addr.bitlen = 32;
-			if (get_u32(a.addr.data, addr, 0)) {
-				if (strcmp(addr, "rtnl") == 0)
-					a.addr.data[0] = 0;
-				else if (strcmp(addr, "fw") == 0)
-					a.addr.data[0] = 3;
-				else if (strcmp(addr, "tcpdiag") == 0)
-					a.addr.data[0] = 4;
-				else
-					return NULL;
-			}
+			if (nl_proto_a2n(&a.addr.data[0], addr) == -1)
+				return NULL;
 		}
 		goto out;
 	}
-- 
2.1.3
