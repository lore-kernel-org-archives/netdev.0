From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] net: netif_device_attach/detach should start/stop all queues
Date: Wed, 08 Apr 2009 16:15:22 -0700
Message-ID: <20090408231519.8537.79219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:55183
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753781AbZDIHns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 03:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently netif_device_attach/detach are only stopping one queue.  They
should be starting and stopping all the queues on a given device.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 91d792d..ea8eb22 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1430,7 +1430,7 @@ void netif_device_detach(struct net_device *dev)
 {
 	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
-		netif_stop_queue(dev);
+		netif_tx_stop_all_queues(dev);
 	}
 }
 EXPORT_SYMBOL(netif_device_detach);
@@ -1445,7 +1445,7 @@ void netif_device_attach(struct net_device *dev)
 {
 	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
-		netif_wake_queue(dev);
+		netif_tx_wake_all_queues(dev);
 		__netdev_watchdog_up(dev);
 	}
 }

