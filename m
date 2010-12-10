From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/27] Documentation/networking/ixgbe.txt: Update ixgbe documentation
Date: Fri, 10 Dec 2010 01:50:45 -0800
Message-ID: <1291974667-30254-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:41121 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753129Ab0LJJvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 04:51:21 -0500
To: davem@davemloft.net
In-Reply-To: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN ixgbe documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/ixgbe.txt |  211 +++++++++++++++++++++++-------------
 1 files changed, 136 insertions(+), 75 deletions(-)

diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
index eeb6868..9ade280 100644
--- a/Documentation/networking/ixgbe.txt
+++ b/Documentation/networking/ixgbe.txt
@@ -1,107 +1,126 @@
 Linux Base Driver for 10 Gigabit PCI Express Intel(R) Network Connection
 ========================================================================
 
-March 10, 2009
-
+Intel Gigabit Linux driver.
+Copyright(c) 1999 - 2010 Intel Corporation.
 
 Contents
 ========
 
-- In This Release
 - Identifying Your Adapter
-- Building and Installation
 - Additional Configurations
+- Performance Tuning
+- Known Issues
 - Support
 
+Identifying Your Adapter
+========================
 
+The driver in this release is compatible with 82598 and 82599-based Intel
+Network Connections.
 
-In This Release
-===============
+For more information on how to identify your adapter, go to the Adapter &
+Driver ID Guide at:
 
-This file describes the ixgbe Linux Base Driver for the 10 Gigabit PCI
-Express Intel(R) Network Connection.  This driver includes support for
-Itanium(R)2-based systems.
+    http://support.intel.com/support/network/sb/CS-012904.htm
 
-For questions related to hardware requirements, refer to the documentation
-supplied with your 10 Gigabit adapter.  All hardware requirements listed apply
-to use with Linux.
+SFP+ Devices with Pluggable Optics
+----------------------------------
 
-The following features are available in this kernel:
- - Native VLANs
- - Channel Bonding (teaming)
- - SNMP
- - Generic Receive Offload
- - Data Center Bridging
+82599-BASED ADAPTERS
 
-Channel Bonding documentation can be found in the Linux kernel source:
-/Documentation/networking/bonding.txt
+NOTES: If your 82599-based Intel(R) Network Adapter came with Intel optics, or
+is an Intel(R) Ethernet Server Adapter X520-2, then it only supports Intel
+optics and/or the direct attach cables listed below.
 
-Ethtool, lspci, and ifconfig can be used to display device and driver
-specific information.
+When 82599-based SFP+ devices are connected back to back, they should be set to
+the same Speed setting via Ethtool. Results may vary if you mix speed settings.
+82598-based adapters support all passive direct attach cables that comply
+with SFF-8431 v4.1 and SFF-8472 v10.4 specifications. Active direct attach
+cables are not supported.
 
+Supplier    Type                                             Part Numbers
 
-Identifying Your Adapter
-========================
+SR Modules
+Intel       DUAL RATE 1G/10G SFP+ SR (bailed)                FTLX8571D3BCV-IT
+Intel       DUAL RATE 1G/10G SFP+ SR (bailed)                AFBR-703SDDZ-IN1
+Intel       DUAL RATE 1G/10G SFP+ SR (bailed)                AFBR-703SDZ-IN2
+LR Modules
+Intel       DUAL RATE 1G/10G SFP+ LR (bailed)                FTLX1471D3BCV-IT
+Intel       DUAL RATE 1G/10G SFP+ LR (bailed)                AFCT-701SDDZ-IN1
+Intel       DUAL RATE 1G/10G SFP+ LR (bailed)                AFCT-701SDZ-IN2
 
-This driver supports devices based on the 82598 controller and the 82599
-controller.
+The following is a list of 3rd party SFP+ modules and direct attach cables that
+have received some testing. Not all modules are applicable to all devices.
 
-For specific information on identifying which adapter you have, please visit:
+Supplier   Type                                              Part Numbers
 
-    http://support.intel.com/support/network/sb/CS-008441.htm
+Finisar    SFP+ SR bailed, 10g single rate                   FTLX8571D3BCL
+Avago      SFP+ SR bailed, 10g single rate                   AFBR-700SDZ
+Finisar    SFP+ LR bailed, 10g single rate                   FTLX1471D3BCL
 
+Finisar    DUAL RATE 1G/10G SFP+ SR (No Bail)                FTLX8571D3QCV-IT
+Avago      DUAL RATE 1G/10G SFP+ SR (No Bail)                AFBR-703SDZ-IN1
+Finisar    DUAL RATE 1G/10G SFP+ LR (No Bail)                FTLX1471D3QCV-IT
+Avago      DUAL RATE 1G/10G SFP+ LR (No Bail)                AFCT-701SDZ-IN1
+Finistar   1000BASE-T SFP                                    FCLF8522P2BTL
+Avago      1000BASE-T SFP                                    ABCU-5710RZ
 
-Building and Installation
-=========================
+82599-based adapters support all passive and active limiting direct attach
+cables that comply with SFF-8431 v4.1 and SFF-8472 v10.4 specifications.
 
-select m for "Intel(R) 10GbE PCI Express adapters support" located at:
-      Location:
-        -> Device Drivers
-          -> Network device support (NETDEVICES [=y])
-            -> Ethernet (10000 Mbit) (NETDEV_10000 [=y])
+Laser turns off for SFP+ when ifconfig down
+-------------------------------------------
+"ifconfig down" turns off the laser for 82599-based SFP+ fiber adapters.
+"ifconfig up" turns on the later.
 
-1. make modules & make modules_install
 
-2. Load the module:
+82598-BASED ADAPTERS
 
-# modprobe ixgbe
+NOTES for 82598-Based Adapters:
+- Intel(R) Network Adapters that support removable optical modules only support
+  their original module type (i.e., the Intel(R) 10 Gigabit SR Dual Port
+  Express Module only supports SR optical modules). If you plug in a different
+  type of module, the driver will not load.
+- Hot Swapping/hot plugging optical modules is not supported.
+- Only single speed, 10 gigabit modules are supported.
+- LAN on Motherboard (LOMs) may support DA, SR, or LR modules. Other module
+  types are not supported. Please see your system documentation for details.
 
-   The insmod command can be used if the full
-   path to the driver module is specified.  For example:
+The following is a list of 3rd party SFP+ modules and direct attach cables that
+have received some testing. Not all modules are applicable to all devices.
 
-     insmod /lib/modules/<KERNEL VERSION>/kernel/drivers/net/ixgbe/ixgbe.ko
+Supplier   Type                                              Part Numbers
 
-   With 2.6 based kernels also make sure that older ixgbe drivers are
-   removed from the kernel, before loading the new module:
+Finisar    SFP+ SR bailed, 10g single rate                   FTLX8571D3BCL
+Avago      SFP+ SR bailed, 10g single rate                   AFBR-700SDZ
+Finisar    SFP+ LR bailed, 10g single rate                   FTLX1471D3BCL
 
-     rmmod ixgbe; modprobe ixgbe
+82598-based adapters support all passive direct attach cables that comply
+with SFF-8431 v4.1 and SFF-8472 v10.4 specifications. Active direct attach
+cables are not supported.
 
-3. Assign an IP address to the interface by entering the following, where
-   x is the interface number:
 
-     ifconfig ethx <IP_address>
+Flow Control
+------------
+Ethernet Flow Control (IEEE 802.3x) can be configured with ethtool to enable
+receiving and transmitting pause frames for ixgbe. When TX is enabled, PAUSE
+frames are generated when the receive packet buffer crosses a predefined
+threshold.  When rx is enabled, the transmit unit will halt for the time delay
+specified when a PAUSE frame is received.
 
-4. Verify that the interface works. Enter the following, where <IP_address>
-   is the IP address for another machine on the same subnet as the interface
-   that is being tested:
+Flow Control is enabled by default. If you want to disable a flow control
+capable link partner, use Ethtool:
 
-     ping  <IP_address>
+     ethtool -A eth? autoneg off RX off TX off
 
+NOTE: For 82598 backplane cards entering 1 gig mode, flow control default
+behavior is changed to off.  Flow control in 1 gig mode on these devices can
+lead to Tx hangs.
 
 Additional Configurations
 =========================
 
-  Viewing Link Messages
-  ---------------------
-  Link messages will not be displayed to the console if the distribution is
-  restricting system messages. In order to see network driver link messages on
-  your console, set dmesg to eight by entering the following:
-
-       dmesg -n 8
-
-  NOTE: This setting is not saved across reboots.
-
-
   Jumbo Frames
   ------------
   The driver supports Jumbo Frames for all adapters. Jumbo Frames support is
@@ -123,13 +142,8 @@ Additional Configurations
   other protocols besides TCP.  It's also safe to use with configurations that
   are problematic for LRO, namely bridging and iSCSI.
 
-  GRO is enabled by default in the driver.  Future versions of ethtool will
-  support disabling and re-enabling GRO on the fly.
-
-
   Data Center Bridging, aka DCB
   -----------------------------
-
   DCB is a configuration Quality of Service implementation in hardware.
   It uses the VLAN priority tag (802.1p) to filter traffic.  That means
   that there are 8 different priorities that traffic can be filtered into.
@@ -163,24 +177,71 @@ Additional Configurations
 
         http://e1000.sf.net
 
-
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
-  diagnostics, as well as displaying statistical information.  Ethtool
-  version 3.0 or later is required for this functionality.
+  diagnostics, as well as displaying statistical information. The latest
+  Ethtool version is required for this functionality.
 
   The latest release of ethtool can be found from
   http://sourceforge.net/projects/gkernel.
 
-
-  NAPI
+  FCoE
   ----
+  This release of the ixgbe driver contains new code to enable users to use
+  Fiber Channel over Ethernet (FCoE) and Data Center Bridging (DCB)
+  functionality that is supported by the 82598-based hardware.  This code has
+  no default effect on the regular driver operation, and configuring DCB and
+  FCoE is outside the scope of this driver README. Refer to
+  http://www.open-fcoe.org/ for FCoE project information and contact
+  e1000-eedc@lists.sourceforge.net for DCB information.
+
+  MAC and VLAN anti-spoofing feature
+  ----------------------------------
+  When a malicious driver attempts to send a spoofed packet, it is dropped by
+  the hardware and not transmitted.  An interrupt is sent to the PF driver
+  notifying it of the spoof attempt.
+
+  When a spoofed packet is detected the PF driver will send the following
+  message to the system log (displayed by  the "dmesg" command):
+
+  Spoof event(s) detected on VF (n)
+
+  Where n=the VF that attempted to do the spoofing.
+
+
+Performance Tuning
+==================
+
+An excellent article on performance tuning can be found at:
+
+http://www.redhat.com/promo/summit/2008/downloads/pdf/Thursday/Mark_Wagner.pdf
+
+
+Known Issues
+============
+
+  Enabling SR-IOV in a 32-bit Microsoft* Windows* Server 2008 Guest OS using
+  Intel (R) 82576-based GbE or Intel (R) 82599-based 10GbE controller under KVM
+  -----------------------------------------------------------------------------
+  KVM Hypervisor/VMM supports direct assignment of a PCIe device to a VM.  This
+  includes traditional PCIe devices, as well as SR-IOV-capable devices using
+  Intel 82576-based and 82599-based controllers.
+
+  While direct assignment of a PCIe device or an SR-IOV Virtual Function (VF)
+  to a Linux-based VM running 2.6.32 or later kernel works fine, there is a
+  known issue with Microsoft Windows Server 2008 VM that results in a "yellow
+  bang" error. This problem is within the KVM VMM itself, not the Intel driver,
+  or the SR-IOV logic of the VMM, but rather that KVM emulates an older CPU
+  model for the guests, and this older CPU model does not support MSI-X
+  interrupts, which is a requirement for Intel SR-IOV.
 
-  NAPI (Rx polling mode) is supported in the ixgbe driver.  NAPI is enabled
-  by default in the driver.
+  If you wish to use the Intel 82576 or 82599-based controllers in SR-IOV mode
+  with KVM and a Microsoft Windows Server 2008 guest try the following
+  workaround. The workaround is to tell KVM to emulate a different model of CPU
+  when using qemu to create the KVM guest:
 
-  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
+       "-cpu qemu64,model=13"
 
 
 Support
-- 
1.7.3.2

