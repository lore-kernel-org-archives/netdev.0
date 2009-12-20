From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] ethtool: Do not report link partner advertising flags if
 set to 0
Date: Sun, 20 Dec 2009 19:12:30 +0000
Message-ID: <1261336350.25157.200.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Kurt Roeckx <kurt@roeckx.be>, 561843@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35511 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754557AbZLTTMj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2009 14:12:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only some drivers (and none before kernel version 2.6.31) currently
set these flags.  When the flags are equal to 0 and so we don't know
what the link partner advertised, don't report anything.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 ethtool.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 10dfc80..298b690 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -948,7 +948,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 
 	dump_supported(ep);
 	dump_advertised(ep, "Advertised", ep->advertising);
-	dump_advertised(ep, "Link partner advertised", ep->lp_advertising);
+	if (ep->lp_advertising)
+		dump_advertised(ep, "Link partner advertised",
+				ep->lp_advertising);
 
 	fprintf(stdout, "	Speed: ");
 	speed = ethtool_cmd_speed(ep);
-- 
1.6.5.7


