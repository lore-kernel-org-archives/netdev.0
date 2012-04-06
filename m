From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/6] doc, net: Update netdev operation names
Date: Fri, 6 Apr 2012 01:39:47 +0100
Message-ID: <1333672787.2652.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28095 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756800Ab2DFAju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:39:50 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits d314774cf2cd5dfeb39a00d37deee65d4c627927 ('netdev: network
device operations infrastructure') and
008298231abbeb91bc7be9e8b078607b816d1a4a ('netdev: add more functions
to netdevice ops') moved and renamed net device operation pointers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/driver.txt     |   12 ++++++------
 Documentation/networking/netdevices.txt |   16 ++++++++--------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index 03283da..83ce060 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -2,7 +2,7 @@ Document about softnet driver issues
 
 Transmit path guidelines:
 
-1) The hard_start_xmit method must never return '1' under any
+1) The ndo_start_xmit method must never return '1' under any
    normal circumstances.  It is considered a hard error unless
    there is no way your device can tell ahead of time when it's
    transmit function will become busy.
@@ -61,10 +61,10 @@ Transmit path guidelines:
 2) Do not forget to update netdev->trans_start to jiffies after
    each new tx packet is given to the hardware.
 
-3) A hard_start_xmit method must not modify the shared parts of a
+3) An ndo_start_xmit method must not modify the shared parts of a
    cloned SKB.
 
-4) Do not forget that once you return 0 from your hard_start_xmit
+4) Do not forget that once you return 0 from your ndo_start_xmit
    method, it is your driver's responsibility to free up the SKB
    and in some finite amount of time.
 
@@ -74,7 +74,7 @@ Transmit path guidelines:
    This error can deadlock sockets waiting for send buffer room
    to be freed up.
 
-   If you return 1 from the hard_start_xmit method, you must not keep
+   If you return 1 from the ndo_start_xmit method, you must not keep
    any reference to that SKB and you must not attempt to free it up.
 
 Probing guidelines:
@@ -85,10 +85,10 @@ Probing guidelines:
 
 Close/stop guidelines:
 
-1) After the dev->stop routine has been called, the hardware must
+1) After the ndo_stop routine has been called, the hardware must
    not receive or transmit any data.  All in flight packets must
    be aborted. If necessary, poll or wait for completion of 
    any reset commands.
 
-2) The dev->stop routine will be called by unregister_netdevice
+2) The ndo_stop routine will be called by unregister_netdevice
    if device is still UP.
diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index b107733..c7ecc70 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -47,24 +47,24 @@ packets is preferred.
 
 struct net_device synchronization rules
 =======================================
-dev->open:
+ndo_open:
 	Synchronization: rtnl_lock() semaphore.
 	Context: process
 
-dev->stop:
+ndo_stop:
 	Synchronization: rtnl_lock() semaphore.
 	Context: process
 	Note: netif_running() is guaranteed false
 
-dev->do_ioctl:
+ndo_do_ioctl:
 	Synchronization: rtnl_lock() semaphore.
 	Context: process
 
-dev->get_stats:
+ndo_get_stats:
 	Synchronization: dev_base_lock rwlock.
 	Context: nominally process, but don't sleep inside an rwlock
 
-dev->hard_start_xmit:
+ndo_start_xmit:
 	Synchronization: __netif_tx_lock spinlock.
 
 	When the driver sets NETIF_F_LLTX in dev->features this will be
@@ -86,12 +86,12 @@ dev->hard_start_xmit:
 	o NETDEV_TX_LOCKED Locking failed, please retry quickly.
 	  Only valid when NETIF_F_LLTX is set.
 
-dev->tx_timeout:
+ndo_tx_timeout:
 	Synchronization: netif_tx_lock spinlock; all TX queues frozen.
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed true
 
-dev->set_rx_mode:
+ndo_set_rx_mode:
 	Synchronization: netif_addr_lock spinlock.
 	Context: BHs disabled
 
@@ -99,7 +99,7 @@ struct napi_struct synchronization rules
 ========================================
 napi->poll:
 	Synchronization: NAPI_STATE_SCHED bit in napi->state.  Device
-		driver's dev->close method will invoke napi_disable() on
+		driver's ndo_stop method will invoke napi_disable() on
 		all NAPI instances which will do a sleeping poll on the
 		NAPI_STATE_SCHED napi->state bit, waiting for all pending
 		NAPI activity to cease.
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
