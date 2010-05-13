From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] sky2: Restore multicast after restart
Date: Thu, 13 May 2010 09:12:48 -0700
Message-ID: <20100513161351.006299145@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39383 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758416Ab0EMXa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:26 -0400
Content-Disposition: inline; filename=sky2-mike2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Multicast settings will be lost on reset, so restore them.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
This regression was introduced in 2.6.34 by
  commit 8a0c9228f110218f443d9ef8f9ab629251959733
  sky2: Avoid down and up during sky2_reset

So please apply to -net as well.


 drivers/net/sky2.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

--- a/drivers/net/sky2.c	2010-05-13 09:02:37.756960274 -0700
+++ b/drivers/net/sky2.c	2010-05-13 09:02:53.528209351 -0700
@@ -3347,6 +3347,7 @@ static void sky2_restart(struct work_str
 			continue;
 
 		sky2_hw_up(sky2);
+		sky2_set_multicast(dev);
 		netif_wake_queue(dev);
 	}
 


