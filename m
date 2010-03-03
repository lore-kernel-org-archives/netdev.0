From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 2/2] ipv4: flush ARP entries on device change
Date: Wed,  3 Mar 2010 16:01:14 +0200
Message-ID: <1267624874-22326-2-git-send-email-timo.teras@iki.fi>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:49505 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361Ab0CCOBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:01:54 -0500
Received: by ey-out-2122.google.com with SMTP id 25so244789eya.19
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 06:01:53 -0800 (PST)
In-Reply-To: <1267624874-22326-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device flag IFF_NOARP is changed, we should flush the ARP cache as all
entries need to get refreshed.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/ipv4/arp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c4dd135..036da92 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1245,6 +1245,9 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event, vo
 		neigh_changeaddr(&arp_tbl, dev);
 		rt_cache_flush(dev_net(dev), 0);
 		break;
+	case NETDEV_CHANGE:
+		neigh_changeaddr(&arp_tbl, dev);
+		break;
 	default:
 		break;
 	}
-- 
1.6.3.3

