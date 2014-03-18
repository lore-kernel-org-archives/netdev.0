From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] igb: remove references to long gone command line parameters
Date: Tue, 18 Mar 2014 00:26:48 -0700
Message-ID: <1395127610-3290-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43006 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbaCRH06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:26:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>

Command line parameters QueuePairs, Node, EEE, DMAC and InterruptThrottleRate
do not exist these days. Remove all references to them in the Documentation
folder and update code comments.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/igb.txt          | 48 -------------------------------
 drivers/net/ethernet/intel/igb/igb_main.c |  6 ++--
 2 files changed, 2 insertions(+), 52 deletions(-)

diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index 4ebbd65..43d3549 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -36,54 +36,6 @@ Default Value: 0
 This parameter adds support for SR-IOV.  It causes the driver to spawn up to
 max_vfs worth of virtual function.
 
-QueuePairs
-----------
-Valid Range:  0-1
-Default Value:  1 (TX and RX will be paired onto one interrupt vector)
-
-If set to 0, when MSI-X is enabled, the TX and RX will attempt to occupy
-separate vectors.
-
-This option can be overridden to 1 if there are not sufficient interrupts
-available.  This can occur if any combination of RSS, VMDQ, and max_vfs
-results in more than 4 queues being used.
-
-Node
-----
-Valid Range:   0-n
-Default Value: -1 (off)
-
-  0 - n: where n is the number of the NUMA node that should be used to
-         allocate memory for this adapter port.
-  -1: uses the driver default of allocating memory on whichever processor is
-      running insmod/modprobe.
-
-  The Node parameter will allow you to pick which NUMA node you want to have
-  the adapter allocate memory from.  All driver structures, in-memory queues,
-  and receive buffers will be allocated on the node specified.  This parameter
-  is only useful when interrupt affinity is specified, otherwise some portion
-  of the time the interrupt could run on a different core than the memory is
-  allocated on, causing slower memory access and impacting throughput, CPU, or
-  both.
-
-EEE
----
-Valid Range:  0-1
-Default Value: 1 (enabled)
-
-  A link between two EEE-compliant devices will result in periodic bursts of
-  data followed by long periods where in the link is in an idle state. This Low
-  Power Idle (LPI) state is supported in both 1Gbps and 100Mbps link speeds.
-  NOTE: EEE support requires autonegotiation.
-
-DMAC
-----
-Valid Range: 0-1
-Default Value: 1 (enabled)
-  Enables or disables DMA Coalescing feature.
-
-
-
 Additional Configurations
 =========================
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d6b1152..ac06492 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4347,8 +4347,7 @@ enum latency_range {
  *  were determined based on theoretical maximum wire speed and testing
  *  data, in order to minimize response time while increasing bulk
  *  throughput.
- *  This functionality is controlled by the InterruptThrottleRate module
- *  parameter (see igb_param.c)
+ *  This functionality is controlled by ethtool's coalescing settings.
  *  NOTE:  This function is called only when operating in a multiqueue
  *         receive environment.
  **/
@@ -4422,8 +4421,7 @@ clear_counts:
  *  based on theoretical maximum wire speed and thresholds were set based
  *  on testing data as well as attempting to minimize response time
  *  while increasing bulk throughput.
- *  this functionality is controlled by the InterruptThrottleRate module
- *  parameter (see igb_param.c)
+ *  This functionality is controlled by ethtool's coalescing settings.
  *  NOTE:  These calculations are only valid when operating in a single-
  *         queue environment.
  **/
-- 
1.8.3.1
