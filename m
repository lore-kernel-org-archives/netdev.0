From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/7] ipaddress: Make buffer for filter.flushb static
Date: Thu, 17 Aug 2017 19:09:25 +0200
Message-ID: <20170817170931.24302-2-phil@nwl.cc>
References: <20170817170931.24302-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52421 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753329AbdHQRLt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:11:49 -0400
In-Reply-To: <20170817170931.24302-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The buffer is accessed outside of the function defining it, so make it
static.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d37c5e045071..3c9decb51b412 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1488,7 +1488,7 @@ static void ipaddr_filter(struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
 static int ipaddr_flush(void)
 {
 	int round = 0;
-	char flushb[4096-512];
+	static char flushb[4096-512];
 
 	filter.flushb = flushb;
 	filter.flushp = 0;
-- 
2.13.1
