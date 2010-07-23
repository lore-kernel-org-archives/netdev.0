From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: use int instead of long for RTAX_HOPLIMIT compare
Date: Fri, 23 Jul 2010 15:39:10 +0200
Message-ID: <20100723133910.GC12942@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-39.dex002.intermedia.net ([64.78.21.124]:58400 "EHLO
	dhost002-39.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755568Ab0GWNlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:41:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise "if ((int)val == -1)" will never match on 64 bit systems

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/iproute.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 04b253a..711576e 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -494,7 +494,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			val = *(unsigned*)RTA_DATA(mxrta[i]);
 			switch (i) {
 			case RTAX_HOPLIMIT:
-				if ((long)val == -1)
+				if ((int)val == -1)
 					val = 0;
 				/* fall through */
 			default:
-- 
1.7.0.4

