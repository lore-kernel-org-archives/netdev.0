From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/6] doc, net: Update documentation of
 synchronisation for TX multiqueue
Date: Fri, 6 Apr 2012 01:39:30 +0100
Message-ID: <1333672770.2652.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28080 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753530Ab2DFAjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:39:33 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits e308a5d806c852f56590ffdd3834d0df0cbed8d7 ('netdev: Add
netdev->addr_list_lock protection.') and
e8a0464cc950972824e2e128028ae3db666ec1ed ('netdev: Allocate multiple
queues for TX.') introduced more fine-grained locks.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/netdevices.txt |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 336fe8e..b107733 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -65,7 +65,7 @@ dev->get_stats:
 	Context: nominally process, but don't sleep inside an rwlock
 
 dev->hard_start_xmit:
-	Synchronization: netif_tx_lock spinlock.
+	Synchronization: __netif_tx_lock spinlock.
 
 	When the driver sets NETIF_F_LLTX in dev->features this will be
 	called without holding netif_tx_lock. In this case the driver
@@ -87,12 +87,12 @@ dev->hard_start_xmit:
 	  Only valid when NETIF_F_LLTX is set.
 
 dev->tx_timeout:
-	Synchronization: netif_tx_lock spinlock.
+	Synchronization: netif_tx_lock spinlock; all TX queues frozen.
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed true
 
 dev->set_rx_mode:
-	Synchronization: netif_tx_lock spinlock.
+	Synchronization: netif_addr_lock spinlock.
 	Context: BHs disabled
 
 struct napi_struct synchronization rules
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
