From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH] sit: fix off-by-one in ipip6_tunnel_get_prl
Date: Tue, 29 Sep 2009 23:27:05 +0200
Message-ID: <1254259625-29320-1-git-send-email-contact@saschahlusiak.de>
Cc: fred.l.templin@boeing.com,
	Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:49185 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZI2V1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 17:27:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When requesting all prl entries (kprl.addr == INADDR_ANY) and there are
more prl entries than there is space passed from userspace, the existing
code would always copy cmax+1 entries, which is more than can be handled.

This patch makes the kernel copy only exactly cmax entries.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
Acked-By: Fred L. Templin <Fred.L.Templin@boeing.com>
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d65e0c4..dbd19a7 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -274,7 +274,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 
 	c = 0;
 	for (prl = t->prl; prl; prl = prl->next) {
-		if (c > cmax)
+		if (c >= cmax)
 			break;
 		if (kprl.addr != htonl(INADDR_ANY) && prl->addr != kprl.addr)
 			continue;
-- 
1.6.5.rc1

