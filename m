From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Fri, 5 Aug 2011 23:23:51 +0400
Message-ID: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48908 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756279Ab1HETYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 15:24:11 -0400
Received: by vxi9 with SMTP id 9so1209713vxi.19
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2011 12:24:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using nanosleep() in an userspace application we get a ratelimit warning:

	NOHZ: local_softirq_pending 08

According to 481a8199142c050b72bff8a1956a49fd0a75bbe0 the problem is caused by
netif_rx() function. This patch replaces netif_rx() with netif_rx_ni() which
has to be used from process/softirq context.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index f11b3f3..4c61753 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -367,7 +367,7 @@ static void sl_bump(struct slip *sl)
 	memcpy(skb_put(skb, count), sl->rbuff, count);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IP);
-	netif_rx(skb);
+	netif_rx_ni(skb);
 	dev->stats.rx_packets++;
 }

-- 
1.7.4.1
