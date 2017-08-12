From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 04/51] ipaddress: Avoid accessing uninitialized variable lcl
Date: Sat, 12 Aug 2017 14:04:23 +0200
Message-ID: <20170812120510.28750-5-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44263 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752564AbdHLMIo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:44 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no address was given, ipaddr_modify() accesses uninitialized data
when assigning to req.ifa.ifa_prefixlen.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3c9decb51b412..9307c9416dde3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1888,7 +1888,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	char  *lcl_arg = NULL;
 	char  *valid_lftp = NULL;
 	char  *preferred_lftp = NULL;
-	inet_prefix lcl;
+	inet_prefix lcl = {};
 	inet_prefix peer;
 	int local_len = 0;
 	int peer_len = 0;
-- 
2.13.1
