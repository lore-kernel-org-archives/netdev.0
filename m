From: David Lamparter <lists@diac24.net>
Subject: [PATCH] iproute2: Format IPv6 tunnels endpoints nicely.
Date: Sat, 9 Jun 2007 15:53:58 +0200
Message-ID: <20070609135356.GA21251@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 91-65-240-14-dynip.superkabel.de ([91.65.240.14]:43652 "EHLO
	charon.n2.diac24.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756911AbXFINyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 09:54:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change formatting of IPv6 tunnel endpoints from hex chain to standard IPv6
representation.

Signed-off-by: David Lamparter <equinox@diac24.net>

---
 lib/ll_addr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/ll_addr.c b/lib/ll_addr.c
index 581487d..f558050 100644
--- a/lib/ll_addr.c
+++ b/lib/ll_addr.c
@@ -38,6 +38,9 @@ const char *ll_addr_n2a(unsigned char *addr, int alen, int type, char *buf, int
 	    (type == ARPHRD_TUNNEL || type == ARPHRD_SIT || type == ARPHRD_IPGRE)) {
 		return inet_ntop(AF_INET, addr, buf, blen);
 	}
+	if (alen == 16 && type == ARPHRD_TUNNEL6) {
+		return inet_ntop(AF_INET6, addr, buf, blen);
+	}
 	l = 0;
 	for (i=0; i<alen; i++) {
 		if (i==0) {
-- 
1.5.0.1

