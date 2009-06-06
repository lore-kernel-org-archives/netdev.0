From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 1/3] sit: ipip6_err: ICMP_PORT_UNREACH is a possible event
Date: Sat,  6 Jun 2009 16:02:50 +0200
Message-ID: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:55505 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbZFFOA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 10:00:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux sends ICMP_DEST_UNREACH + ICMP_PORT_UNREACH itself in ipip6_rcv,
if no matching tunnel is found.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b3a59bd..ba74094 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -494,7 +494,6 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
-		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
 			return 0;
 		case ICMP_FRAG_NEEDED:
-- 
1.6.3.1

