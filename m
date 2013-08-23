From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/2] Documentation/networking/: Update Intel wired LAN driver documentation
Date: Fri, 23 Aug 2013 05:29:20 -0700
Message-ID: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61902 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756013Ab3HWM3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 08:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updates the documentation to the Intel wired LAN drivers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 Documentation/networking/e100.txt    |  20 ++++---
 Documentation/networking/e1000.txt   |  12 ++--
 Documentation/networking/e1000e.txt  |  16 +++--
 Documentation/networking/igb.txt     |  67 +++++++++++++++++++--
 Documentation/networking/igbvf.txt   |   8 +--
 Documentation/networking/ixgb.txt    |  14 ++---
 Documentation/networking/ixgbe.txt   | 109 +++++++++++++++++++++++++++++++----
 Documentation/networking/ixgbevf.txt |   6 +-
 8 files changed, 204 insertions(+), 48 deletions(-)

diff --git a/Documentation/networking/e100.txt b/Documentation/networking/e100.txt
index fcb6c71c..cb05838 100644
--- a/Documentation/networking/e100.txt
+++ b/Documentation/networking/e100.txt
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
 ==============================================================
 
-November 15, 2005
+March 15, 2011
 
 Contents
 ========
@@ -94,8 +94,8 @@ Additional Configurations
 
   Configuring a network driver to load properly when the system is started is
   distribution dependent. Typically, the configuration process involves adding
-  an alias line to /etc/modprobe.d/*.conf as well as editing other system
-  startup scripts and/or configuration files.  Many popular Linux
+  an alias line to /etc/modules.conf or /etc/modprobe.conf as well as editing
+  other system startup scripts and/or configuration files.  Many popular Linux
   distributions ship with tools to make these changes for you. To learn the
   proper way to configure a network device for your system, refer to your
   distribution documentation.  If during this process you are asked for the
@@ -103,7 +103,7 @@ Additional Configurations
   PRO/100 Family of Adapters is e100.
 
   As an example, if you install the e100 driver for two PRO/100 adapters
-  (eth0 and eth1), add the following to a configuraton file in /etc/modprobe.d/
+  (eth0 and eth1), add the following to modules.conf or modprobe.conf:
 
        alias eth0 e100
        alias eth1 e100
@@ -122,7 +122,7 @@ Additional Configurations
   NOTE: This setting is not saved across reboots.
 
 
-  Ethtool
+  ethtool
   -------
 
   The driver utilizes the ethtool interface for driver configuration and
@@ -134,13 +134,19 @@ Additional Configurations
 
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is provided through the ethtool* utility.  For instructions on enabling
-  WoL with ethtool, refer to the ethtool man page.
+  WoL is provided through the ethtool* utility. The ethtool utility is included
+  with Red Hat* 8.0. For other Linux distributions, download and install
+  ethtool from the following website:
+
+  http://ftp.kernel.org/pub/software/network/ethtool/
+
+  For instructions on enabling WoL with ethtool, refer to the ethtool man page.
 
   WoL will be enabled on the system during the next shut down or reboot. For
   this driver version, in order to enable WoL, the e100 driver must be
   loaded when shutting down or rebooting the system.
 
+
   NAPI
   ----
 
diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/e1000.txt
index 71ca958..437b209 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -1,8 +1,8 @@
-Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
-===============================================================
+Linux* Base Driver for Intel(R) Ethernet Network Connection
+===========================================================
 
 Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
@@ -420,15 +420,15 @@ Additional Configurations
   - The maximum MTU setting for Jumbo Frames is 16110.  This value coincides
     with the maximum Jumbo Frames size of 16128.
 
-  - Using Jumbo Frames at 10 or 100 Mbps may result in poor performance or
-    loss of link.
+  - Using Jumbo frames at 10 or 100 Mbps is not supported and may result in
+    poor performance or loss of link.
 
   - Adapters based on the Intel(R) 82542 and 82573V/E controller do not
     support Jumbo Frames. These correspond to the following product names:
      Intel(R) PRO/1000 Gigabit Server Adapter
      Intel(R) PRO/1000 PM Network Connection
 
-  Ethtool
+  ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information.  The ethtool
diff --git a/Documentation/networking/e1000e.txt b/Documentation/networking/e1000e.txt
index 97b5ba9..ad2d9f3 100644
--- a/Documentation/networking/e1000e.txt
+++ b/Documentation/networking/e1000e.txt
@@ -1,8 +1,8 @@
-Linux* Driver for Intel(R) Network Connection
-=============================================
+Linux* Driver for Intel(R) Ethernet Network Connection
+======================================================
 
 Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
@@ -259,13 +259,16 @@ Additional Configurations
   - The maximum MTU setting for Jumbo Frames is 9216.  This value coincides
     with the maximum Jumbo Frames size of 9234 bytes.
 
-  - Using Jumbo Frames at 10 or 100 Mbps is not supported and may result in
+  - Using Jumbo frames at 10 or 100 Mbps is not supported and may result in
     poor performance or loss of link.
 
   - Some adapters limit Jumbo Frames sized packets to a maximum of
     4096 bytes and some adapters do not support Jumbo Frames.
 
-  Ethtool
+  - Jumbo Frames cannot be configured on an 82579-based Network device, if
+    MACSec is enabled on the system.
+
+  ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information.  We
@@ -273,6 +276,9 @@ Additional Configurations
 
   http://ftp.kernel.org/pub/software/network/ethtool/
 
+  NOTE: When validating enable/disable tests on some parts (82578, for example)
+  you need to add a few seconds between tests when working with ethtool.
+
   Speed and Duplex
   ----------------
   Speed and Duplex are configured through the ethtool* utility. For
diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
index 9a2a037..4ebbd65 100644
--- a/Documentation/networking/igb.txt
+++ b/Documentation/networking/igb.txt
@@ -1,8 +1,8 @@
-Linux* Base Driver for Intel(R) Network Connection
-==================================================
+Linux* Base Driver for Intel(R) Ethernet Network Connection
+===========================================================
 
 Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
@@ -36,6 +36,53 @@ Default Value: 0
 This parameter adds support for SR-IOV.  It causes the driver to spawn up to
 max_vfs worth of virtual function.
 
+QueuePairs
+----------
+Valid Range:  0-1
+Default Value:  1 (TX and RX will be paired onto one interrupt vector)
+
+If set to 0, when MSI-X is enabled, the TX and RX will attempt to occupy
+separate vectors.
+
+This option can be overridden to 1 if there are not sufficient interrupts
+available.  This can occur if any combination of RSS, VMDQ, and max_vfs
+results in more than 4 queues being used.
+
+Node
+----
+Valid Range:   0-n
+Default Value: -1 (off)
+
+  0 - n: where n is the number of the NUMA node that should be used to
+         allocate memory for this adapter port.
+  -1: uses the driver default of allocating memory on whichever processor is
+      running insmod/modprobe.
+
+  The Node parameter will allow you to pick which NUMA node you want to have
+  the adapter allocate memory from.  All driver structures, in-memory queues,
+  and receive buffers will be allocated on the node specified.  This parameter
+  is only useful when interrupt affinity is specified, otherwise some portion
+  of the time the interrupt could run on a different core than the memory is
+  allocated on, causing slower memory access and impacting throughput, CPU, or
+  both.
+
+EEE
+---
+Valid Range:  0-1
+Default Value: 1 (enabled)
+
+  A link between two EEE-compliant devices will result in periodic bursts of
+  data followed by long periods where in the link is in an idle state. This Low
+  Power Idle (LPI) state is supported in both 1Gbps and 100Mbps link speeds.
+  NOTE: EEE support requires autonegotiation.
+
+DMAC
+----
+Valid Range: 0-1
+Default Value: 1 (enabled)
+  Enables or disables DMA Coalescing feature.
+
+
 
 Additional Configurations
 =========================
@@ -55,10 +102,10 @@ Additional Configurations
   - The maximum MTU setting for Jumbo Frames is 9216.  This value coincides
     with the maximum Jumbo Frames size of 9234 bytes.
 
-  - Using Jumbo Frames at 10 or 100 Mbps may result in poor performance or
-    loss of link.
+  - Using Jumbo frames at 10 or 100 Mbps is not supported and may result in
+    poor performance or loss of link.
 
-  Ethtool
+  ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information. The latest
@@ -106,6 +153,14 @@ Additional Configurations
 
   Where n=the VF that attempted to do the spoofing.
 
+  Setting MAC Address, VLAN and Rate Limit Using IProute2 Tool
+  ------------------------------------------------------------
+  You can set a MAC address of a Virtual Function (VF), a default VLAN and the
+  rate limit using the IProute2 tool. Download the latest version of the
+  iproute2 tool from Sourceforge if your version does not have all the
+  features you require.
+
+
 Support
 =======
 
diff --git a/Documentation/networking/igbvf.txt b/Documentation/networking/igbvf.txt
index cbfe4ee..40db17a 100644
--- a/Documentation/networking/igbvf.txt
+++ b/Documentation/networking/igbvf.txt
@@ -1,8 +1,8 @@
-Linux* Base Driver for Intel(R) Network Connection
-==================================================
+Linux* Base Driver for Intel(R) Ethernet Network Connection
+===========================================================
 
 Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
@@ -55,7 +55,7 @@ networking link on the left to search for your adapter:
 Additional Configurations
 =========================
 
-  Ethtool
+  ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information.  The ethtool
diff --git a/Documentation/networking/ixgb.txt b/Documentation/networking/ixgb.txt
index d75a1f9..1e0c045 100644
--- a/Documentation/networking/ixgb.txt
+++ b/Documentation/networking/ixgb.txt
@@ -1,7 +1,7 @@
-Linux Base Driver for 10 Gigabit Intel(R) Network Connection
-=============================================================
+Linux Base Driver for 10 Gigabit Intel(R) Ethernet Network Connection
+=====================================================================
 
-October 9, 2007
+March 14, 2011
 
 
 Contents
@@ -274,9 +274,9 @@ Additional Configurations
   -------------------------------------------------
   Configuring a network driver to load properly when the system is started is
   distribution dependent. Typically, the configuration process involves adding
-  an alias line to files in /etc/modprobe.d/ as well as editing other system
-  startup scripts and/or configuration files.  Many popular Linux distributions
-  ship with tools to make these changes for you.  To learn the proper way to
+  an alias line to /etc/modprobe.conf as well as editing other system startup
+  scripts and/or configuration files.  Many popular Linux distributions ship
+  with tools to make these changes for you.  To learn the proper way to
   configure a network device for your system, refer to your distribution
   documentation.  If during this process you are asked for the driver or module
   name, the name for the Linux Base Driver for the Intel 10GbE Family of
@@ -306,7 +306,7 @@ Additional Configurations
   with the maximum Jumbo Frames size of 16128.
 
 
-  Ethtool
+  ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
   diagnostics, as well as displaying statistical information.  The ethtool
diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
index af77ed3..96ccceb 100644
--- a/Documentation/networking/ixgbe.txt
+++ b/Documentation/networking/ixgbe.txt
@@ -1,8 +1,9 @@
-Linux Base Driver for 10 Gigabit PCI Express Intel(R) Network Connection
-========================================================================
+Linux* Base Driver for the Intel(R) Ethernet 10 Gigabit PCI Express Family of
+Adapters
+=============================================================================
 
-Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Intel 10 Gigabit Linux driver.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
@@ -16,8 +17,8 @@ Contents
 Identifying Your Adapter
 ========================
 
-The driver in this release is compatible with 82598 and 82599-based Intel
-Network Connections.
+The driver in this release is compatible with 82598, 82599 and X540-based
+Intel Network Connections.
 
 For more information on how to identify your adapter, go to the Adapter &
 Driver ID Guide at:
@@ -72,7 +73,7 @@ cables that comply with SFF-8431 v4.1 and SFF-8472 v10.4 specifications.
 Laser turns off for SFP+ when ifconfig down
 -------------------------------------------
 "ifconfig down" turns off the laser for 82599-based SFP+ fiber adapters.
-"ifconfig up" turns on the later.
+"ifconfig up" turns on the laser.
 
 
 82598-BASED ADAPTERS
@@ -118,6 +119,93 @@ NOTE: For 82598 backplane cards entering 1 gig mode, flow control default
 behavior is changed to off.  Flow control in 1 gig mode on these devices can
 lead to Tx hangs.
 
+Intel(R) Ethernet Flow Director
+-------------------------------
+Supports advanced filters that direct receive packets by their flows to
+different queues. Enables tight control on routing a flow in the platform.
+Matches flows and CPU cores for flow affinity. Supports multiple parameters
+for flexible flow classification and load balancing.
+
+Flow director is enabled only if the kernel is multiple TX queue capable.
+
+An included script (set_irq_affinity.sh) automates setting the IRQ to CPU
+affinity.
+
+You can verify that the driver is using Flow Director by looking at the counter
+in ethtool: fdir_miss and fdir_match.
+
+Other ethtool Commands:
+To enable Flow Director
+	ethtool -K ethX ntuple on
+To add a filter
+	Use -U switch. e.g., ethtool -U ethX flow-type tcp4 src-ip 0x178000a
+        action 1
+To see the list of filters currently present:
+	ethtool -u ethX
+
+Perfect Filter: Perfect filter is an interface to load the filter table that
+funnels all flow into queue_0 unless an alternative queue is specified using
+"action". In that case, any flow that matches the filter criteria will be
+directed to the appropriate queue.
+
+If the queue is defined as -1, filter will drop matching packets.
+
+To account for filter matches and misses, there are two stats in ethtool:
+fdir_match and fdir_miss. In addition, rx_queue_N_packets shows the number of
+packets processed by the Nth queue.
+
+NOTE: Receive Packet Steering (RPS) and Receive Flow Steering (RFS) are not
+compatible with Flow Director. IF Flow Director is enabled, these will be
+disabled.
+
+The following three parameters impact Flow Director.
+
+FdirMode
+--------
+Valid Range: 0-2 (0=off, 1=ATR, 2=Perfect filter mode)
+Default Value: 1
+
+  Flow Director filtering modes.
+
+FdirPballoc
+-----------
+Valid Range: 0-2 (0=64k, 1=128k, 2=256k)
+Default Value: 0
+
+  Flow Director allocated packet buffer size.
+
+AtrSampleRate
+--------------
+Valid Range: 1-100
+Default Value: 20
+
+  Software ATR Tx packet sample rate. For example, when set to 20, every 20th
+  packet, looks to see if the packet will create a new flow.
+
+Node
+----
+Valid Range:   0-n
+Default Value: 1 (off)
+
+  0 - n: where n is the number of NUMA nodes (i.e. 0 - 3) currently online in
+  your system
+  1: turns this option off
+
+  The Node parameter will allow you to pick which NUMA node you want to have
+  the adapter allocate memory on.
+
+max_vfs
+-------
+Valid Range:   1-63
+Default Value: 0
+
+  If the value is greater than 0 it will also force the VMDq parameter to be 1
+  or more.
+
+  This parameter adds support for SR-IOV.  It causes the driver to spawn up to
+  max_vfs worth of virtual function.
+
+
 Additional Configurations
 =========================
 
@@ -221,9 +309,10 @@ http://www.redhat.com/promo/summit/2008/downloads/pdf/Thursday/Mark_Wagner.pdf
 Known Issues
 ============
 
-  Enabling SR-IOV in a 32-bit Microsoft* Windows* Server 2008 Guest OS using
-  Intel (R) 82576-based GbE or Intel (R) 82599-based 10GbE controller under KVM
-  -----------------------------------------------------------------------------
+  Enabling SR-IOV in a 32-bit or 64-bit Microsoft* Windows* Server 2008/R2
+  Guest OS using Intel (R) 82576-based GbE or Intel (R) 82599-based 10GbE
+  controller under KVM
+  ------------------------------------------------------------------------
   KVM Hypervisor/VMM supports direct assignment of a PCIe device to a VM.  This
   includes traditional PCIe devices, as well as SR-IOV-capable devices using
   Intel 82576-based and 82599-based controllers.
diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/ixgbevf.txt
index 5a91a41..53d8d2a 100644
--- a/Documentation/networking/ixgbevf.txt
+++ b/Documentation/networking/ixgbevf.txt
@@ -1,8 +1,8 @@
-Linux* Base Driver for Intel(R) Network Connection
-==================================================
+Linux* Base Driver for Intel(R) Ethernet Network Connection
+===========================================================
 
 Intel Gigabit Linux driver.
-Copyright(c) 1999 - 2010 Intel Corporation.
+Copyright(c) 1999 - 2013 Intel Corporation.
 
 Contents
 ========
-- 
1.8.3.1
