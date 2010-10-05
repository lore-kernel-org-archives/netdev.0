From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] e1000.txt: Update e1000 documentation
Date: Tue, 05 Oct 2010 04:17:05 -0700
Message-ID: <20101005111704.23000.60972.stgit@localhost.localdomain>
References: <20101005111643.23000.38976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:50804
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265Ab0JELR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 07:17:26 -0400
In-Reply-To: <20101005111643.23000.38976.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated the e1000 networking driver documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/e1000.txt |  373 +++++++++---------------------------
 1 files changed, 96 insertions(+), 277 deletions(-)

diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/e1000.txt
index 2df7186..d9271e7 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -1,82 +1,35 @@
 Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
 ===============================================================
 
-September 26, 2006
-
+Intel Gigabit Linux driver.
+Copyright(c) 1999 - 2010 Intel Corporation.
 
 Contents
 ========
 
-- In This Release
 - Identifying Your Adapter
-- Building and Installation
 - Command Line Parameters
 - Speed and Duplex Configuration
 - Additional Configurations
-- Known Issues
 - Support
 
-
-In This Release
-===============
-
-This file describes the Linux* Base Driver for the Intel(R) PRO/1000 Family
-of Adapters.  This driver includes support for Itanium(R)2-based systems.
-
-For questions related to hardware requirements, refer to the documentation
-supplied with your Intel PRO/1000 adapter. All hardware requirements listed
-apply to use with Linux.
-
-The following features are now available in supported kernels:
- - Native VLANs
- - Channel Bonding (teaming)
- - SNMP
-
-Channel Bonding documentation can be found in the Linux kernel source:
-/Documentation/networking/bonding.txt
-
-The driver information previously displayed in the /proc filesystem is not
-supported in this release.  Alternatively, you can use ethtool (version 1.6
-or later), lspci, and ifconfig to obtain the same information.
-
-Instructions on updating ethtool can be found in the section "Additional
-Configurations" later in this document.
-
-NOTE: The Intel(R) 82562v 10/100 Network Connection only provides 10/100
-support.
-
-
 Identifying Your Adapter
 ========================
 
 For more information on how to identify your adapter, go to the Adapter &
 Driver ID Guide at:
 
-    http://support.intel.com/support/network/adapter/pro100/21397.htm
+    http://support.intel.com/support/go/network/adapter/idguide.htm
 
 For the latest Intel network drivers for Linux, refer to the following
 website.  In the search field, enter your adapter name or type, or use the
 networking link on the left to search for your adapter:
 
-    http://downloadfinder.intel.com/scripts-df/support_intel.asp
-
+    http://support.intel.com/support/go/network/adapter/home.htm
 
 Command Line Parameters
 =======================
 
-If the driver is built as a module, the  following optional parameters
-are used by entering them on the command line with the modprobe command
-using this syntax:
-
-     modprobe e1000 [<option>=<VAL1>,<VAL2>,...]
-
-For example, with two PRO/1000 PCI adapters, entering:
-
-     modprobe e1000 TxDescriptors=80,128
-
-loads the e1000 driver with 80 TX descriptors for the first adapter and
-128 TX descriptors for the second adapter.
-
 The default value for each parameter is generally the recommended setting,
 unless otherwise noted.
 
@@ -89,10 +42,6 @@ NOTES:  For more information about the AutoNeg, Duplex, and Speed
         parameters, see the application note at:
         http://www.intel.com/design/network/applnots/ap450.htm
 
-        A descriptor describes a data buffer and attributes related to
-        the data buffer.  This information is accessed by the hardware.
-
-
 AutoNeg
 -------
 (Supported only on adapters with copper connections)
@@ -106,7 +55,6 @@ Duplex parameters must not be specified.
 NOTE:  Refer to the Speed and Duplex section of this readme for more
        information on the AutoNeg parameter.
 
-
 Duplex
 ------
 (Supported only on adapters with copper connections)
@@ -119,7 +67,6 @@ set to auto-negotiate, the board auto-detects the correct duplex.  If the
 link partner is forced (either full or half), Duplex defaults to half-
 duplex.
 
-
 FlowControl
 -----------
 Valid Range:   0-3 (0=none, 1=Rx only, 2=Tx only, 3=Rx&Tx)
@@ -128,16 +75,16 @@ Default Value: Reads flow control settings from the EEPROM
 This parameter controls the automatic generation(Tx) and response(Rx)
 to Ethernet PAUSE frames.
 
-
 InterruptThrottleRate
 ---------------------
 (not supported on Intel(R) 82542, 82543 or 82544-based adapters)
-Valid Range:   0,1,3,100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
+Valid Range:   0,1,3,4,100-100000 (0=off, 1=dynamic, 3=dynamic conservative,
+                                   4=simplified balancing)
 Default Value: 3
 
 The driver can limit the amount of interrupts per second that the adapter
-will generate for incoming packets. It does this by writing a value to the 
-adapter that is based on the maximum amount of interrupts that the adapter 
+will generate for incoming packets. It does this by writing a value to the
+adapter that is based on the maximum amount of interrupts that the adapter
 will generate per second.
 
 Setting InterruptThrottleRate to a value greater or equal to 100
@@ -146,37 +93,43 @@ per second, even if more packets have come in. This reduces interrupt
 load on the system and can lower CPU utilization under heavy load,
 but will increase latency as packets are not processed as quickly.
 
-The default behaviour of the driver previously assumed a static 
-InterruptThrottleRate value of 8000, providing a good fallback value for 
-all traffic types,but lacking in small packet performance and latency. 
-The hardware can handle many more small packets per second however, and 
+The default behaviour of the driver previously assumed a static
+InterruptThrottleRate value of 8000, providing a good fallback value for
+all traffic types,but lacking in small packet performance and latency.
+The hardware can handle many more small packets per second however, and
 for this reason an adaptive interrupt moderation algorithm was implemented.
 
 Since 7.3.x, the driver has two adaptive modes (setting 1 or 3) in which
-it dynamically adjusts the InterruptThrottleRate value based on the traffic 
+it dynamically adjusts the InterruptThrottleRate value based on the traffic
 that it receives. After determining the type of incoming traffic in the last
-timeframe, it will adjust the InterruptThrottleRate to an appropriate value 
+timeframe, it will adjust the InterruptThrottleRate to an appropriate value
 for that traffic.
 
 The algorithm classifies the incoming traffic every interval into
-classes.  Once the class is determined, the InterruptThrottleRate value is 
-adjusted to suit that traffic type the best. There are three classes defined: 
+classes.  Once the class is determined, the InterruptThrottleRate value is
+adjusted to suit that traffic type the best. There are three classes defined:
 "Bulk traffic", for large amounts of packets of normal size; "Low latency",
 for small amounts of traffic and/or a significant percentage of small
-packets; and "Lowest latency", for almost completely small packets or 
+packets; and "Lowest latency", for almost completely small packets or
 minimal traffic.
 
-In dynamic conservative mode, the InterruptThrottleRate value is set to 4000 
-for traffic that falls in class "Bulk traffic". If traffic falls in the "Low 
-latency" or "Lowest latency" class, the InterruptThrottleRate is increased 
+In dynamic conservative mode, the InterruptThrottleRate value is set to 4000
+for traffic that falls in class "Bulk traffic". If traffic falls in the "Low
+latency" or "Lowest latency" class, the InterruptThrottleRate is increased
 stepwise to 20000. This default mode is suitable for most applications.
 
 For situations where low latency is vital such as cluster or
 grid computing, the algorithm can reduce latency even more when
 InterruptThrottleRate is set to mode 1. In this mode, which operates
-the same as mode 3, the InterruptThrottleRate will be increased stepwise to 
+the same as mode 3, the InterruptThrottleRate will be increased stepwise to
 70000 for traffic in class "Lowest latency".
 
+In simplified mode the interrupt rate is based on the ratio of Tx and
+Rx traffic.  If the bytes per second rate is approximately equal, the
+interrupt rate will drop as low as 2000 interrupts per second.  If the
+traffic is mostly transmit or mostly receive, the interrupt rate could
+be as high as 8000.
+
 Setting InterruptThrottleRate to 0 turns off any interrupt moderation
 and may improve small packet latency, but is generally not suitable
 for bulk throughput traffic.
@@ -212,8 +165,6 @@ NOTE:  When e1000 is loaded with default settings and multiple adapters
        be platform-specific.  If CPU utilization is not a concern, use
        RX_POLLING (NAPI) and default driver settings.
 
-
-
 RxDescriptors
 -------------
 Valid Range:   80-256 for 82542 and 82543-based adapters
@@ -225,15 +176,14 @@ by the driver.  Increasing this value allows the driver to buffer more
 incoming packets, at the expense of increased system memory utilization.
 
 Each descriptor is 16 bytes.  A receive buffer is also allocated for each
-descriptor and can be either 2048, 4096, 8192, or 16384 bytes, depending 
+descriptor and can be either 2048, 4096, 8192, or 16384 bytes, depending
 on the MTU setting. The maximum MTU size is 16110.
 
-NOTE:  MTU designates the frame size.  It only needs to be set for Jumbo 
-       Frames.  Depending on the available system resources, the request 
-       for a higher number of receive descriptors may be denied.  In this 
+NOTE:  MTU designates the frame size.  It only needs to be set for Jumbo
+       Frames.  Depending on the available system resources, the request
+       for a higher number of receive descriptors may be denied.  In this
        case, use a lower number.
 
-
 RxIntDelay
 ----------
 Valid Range:   0-65535 (0=off)
@@ -254,7 +204,6 @@ CAUTION:  When setting RxIntDelay to a value other than 0, adapters may
           restoring the network connection.  To eliminate the potential
           for the hang ensure that RxIntDelay is set to 0.
 
-
 RxAbsIntDelay
 -------------
 (This parameter is supported only on 82540, 82545 and later adapters.)
@@ -268,7 +217,6 @@ packet is received within the set amount of time.  Proper tuning,
 along with RxIntDelay, may improve traffic throughput in specific network
 conditions.
 
-
 Speed
 -----
 (This parameter is supported only on adapters with copper connections.)
@@ -280,7 +228,6 @@ Speed forces the line speed to the specified value in megabits per second
 partner is set to auto-negotiate, the board will auto-detect the correct
 speed.  Duplex should also be set when Speed is set to either 10 or 100.
 
-
 TxDescriptors
 -------------
 Valid Range:   80-256 for 82542 and 82543-based adapters
@@ -295,6 +242,36 @@ NOTE:  Depending on the available system resources, the request for a
        higher number of transmit descriptors may be denied.  In this case,
        use a lower number.
 
+TxDescriptorStep
+----------------
+Valid Range:    1 (use every Tx Descriptor)
+		4 (use every 4th Tx Descriptor)
+
+Default Value:  1 (use every Tx Descriptor)
+
+On certain non-Intel architectures, it has been observed that intense TX
+traffic bursts of short packets may result in an improper descriptor
+writeback. If this occurs, the driver will report a "TX Timeout" and reset
+the adapter, after which the transmit flow will restart, though data may
+have stalled for as much as 10 seconds before it resumes.
+
+The improper writeback does not occur on the first descriptor in a system
+memory cache-line, which is typically 32 bytes, or 4 descriptors long.
+
+Setting TxDescriptorStep to a value of 4 will ensure that all TX descriptors
+are aligned to the start of a system memory cache line, and so this problem
+will not occur.
+
+NOTES: Setting TxDescriptorStep to 4 effectively reduces the number of
+       TxDescriptors available for transmits to 1/4 of the normal allocation.
+       This has a possible negative performance impact, which may be
+       compensated for by allocating more descriptors using the TxDescriptors
+       module parameter.
+
+       There are other conditions which may result in "TX Timeout", which will
+       not be resolved by the use of the TxDescriptorStep parameter. As the
+       issue addressed by this parameter has never been observed on Intel
+       Architecture platforms, it should not be used on Intel platforms.
 
 TxIntDelay
 ----------
@@ -307,7 +284,6 @@ efficiency if properly tuned for specific network traffic.  If the
 system is reporting dropped transmits, this value may be set too high
 causing the driver to run out of available transmit descriptors.
 
-
 TxAbsIntDelay
 -------------
 (This parameter is supported only on 82540, 82545 and later adapters.)
@@ -330,6 +306,35 @@ Default Value: 1
 A value of '1' indicates that the driver should enable IP checksum
 offload for received packets (both UDP and TCP) to the adapter hardware.
 
+Copybreak
+---------
+Valid Range:   0-xxxxxxx (0=off)
+Default Value: 256
+Usage: insmod e1000.ko copybreak=128
+
+Driver copies all packets below or equaling this size to a fresh Rx
+buffer before handing it up the stack.
+
+This parameter is different than other parameters, in that it is a
+single (not 1,1,1 etc.) parameter applied to all driver instances and
+it is also available during runtime at
+/sys/module/e1000/parameters/copybreak
+
+SmartPowerDownEnable
+--------------------
+Valid Range: 0-1
+Default Value:  0 (disabled)
+
+Allows PHY to turn off in lower power states. The user can turn off
+this parameter in supported chipsets.
+
+KumeranLockLoss
+---------------
+Valid Range: 0-1
+Default Value: 1 (enabled)
+
+This workaround skips resetting the PHY at shutdown for the initial
+silicon releases of ICH8 systems.
 
 Speed and Duplex Configuration
 ==============================
@@ -385,40 +390,9 @@ If the link partner is forced to a specific speed and duplex, then this
 parameter should not be used.  Instead, use the Speed and Duplex parameters
 previously mentioned to force the adapter to the same speed and duplex.
 
-
 Additional Configurations
 =========================
 
-  Configuring the Driver on Different Distributions
-  -------------------------------------------------
-  Configuring a network driver to load properly when the system is started
-  is distribution dependent.  Typically, the configuration process involves
-  adding an alias line to /etc/modules.conf or /etc/modprobe.conf as well
-  as editing other system startup scripts and/or configuration files.  Many
-  popular Linux distributions ship with tools to make these changes for you.
-  To learn the proper way to configure a network device for your system,
-  refer to your distribution documentation.  If during this process you are
-  asked for the driver or module name, the name for the Linux Base Driver
-  for the Intel(R) PRO/1000 Family of Adapters is e1000.
-
-  As an example, if you install the e1000 driver for two PRO/1000 adapters
-  (eth0 and eth1) and set the speed and duplex to 10full and 100half, add
-  the following to modules.conf or or modprobe.conf:
-
-       alias eth0 e1000
-       alias eth1 e1000
-       options e1000 Speed=10,100 Duplex=2,1
-
-  Viewing Link Messages
-  ---------------------
-  Link messages will not be displayed to the console if the distribution is
-  restricting system messages.  In order to see network driver link messages
-  on your console, set dmesg to eight by entering the following:
-
-       dmesg -n 8
-
-  NOTE: This setting is not saved across reboots.
-
   Jumbo Frames
   ------------
   Jumbo Frames support is enabled by changing the MTU to a value larger than
@@ -437,9 +411,11 @@ Additional Configurations
    setting in a different location.
 
   Notes:
-
-  - To enable Jumbo Frames, increase the MTU size on the interface beyond
-    1500.
+  Degradation in throughput performance may be observed in some Jumbo frames
+  environments. If this is observed, increasing the application's socket buffer
+  size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry values may help.
+  See the specific application manual and /usr/src/linux*/Documentation/
+  networking/ip-sysctl.txt for more details.
 
   - The maximum MTU setting for Jumbo Frames is 16110.  This value coincides
     with the maximum Jumbo Frames size of 16128.
@@ -447,40 +423,11 @@ Additional Configurations
   - Using Jumbo Frames at 10 or 100 Mbps may result in poor performance or
     loss of link.
 
-  - Some Intel gigabit adapters that support Jumbo Frames have a frame size
-    limit of 9238 bytes, with a corresponding MTU size limit of 9216 bytes.
-    The adapters with this limitation are based on the Intel(R) 82571EB,
-    82572EI, 82573L and 80003ES2LAN controller.  These correspond to the
-    following product names:
-     Intel(R) PRO/1000 PT Server Adapter
-     Intel(R) PRO/1000 PT Desktop Adapter
-     Intel(R) PRO/1000 PT Network Connection
-     Intel(R) PRO/1000 PT Dual Port Server Adapter
-     Intel(R) PRO/1000 PT Dual Port Network Connection
-     Intel(R) PRO/1000 PF Server Adapter
-     Intel(R) PRO/1000 PF Network Connection
-     Intel(R) PRO/1000 PF Dual Port Server Adapter
-     Intel(R) PRO/1000 PB Server Connection
-     Intel(R) PRO/1000 PL Network Connection
-     Intel(R) PRO/1000 EB Network Connection with I/O Acceleration
-     Intel(R) PRO/1000 EB Backplane Connection with I/O Acceleration
-     Intel(R) PRO/1000 PT Quad Port Server Adapter
-
   - Adapters based on the Intel(R) 82542 and 82573V/E controller do not
     support Jumbo Frames. These correspond to the following product names:
      Intel(R) PRO/1000 Gigabit Server Adapter
      Intel(R) PRO/1000 PM Network Connection
 
-  - The following adapters do not support Jumbo Frames:
-     Intel(R) 82562V 10/100 Network Connection
-     Intel(R) 82566DM Gigabit Network Connection
-     Intel(R) 82566DC Gigabit Network Connection
-     Intel(R) 82566MM Gigabit Network Connection
-     Intel(R) 82566MC Gigabit Network Connection
-     Intel(R) 82562GT 10/100 Network Connection
-     Intel(R) 82562G 10/100 Network Connection
-
-
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
@@ -490,142 +437,14 @@ Additional Configurations
   The latest release of ethtool can be found from
   http://sourceforge.net/projects/gkernel.
 
-  NOTE: Ethtool 1.6 only supports a limited set of ethtool options.  Support
-  for a more complete ethtool feature set can be enabled by upgrading
-  ethtool to ethtool-1.8.1.
-
   Enabling Wake on LAN* (WoL)
   ---------------------------
-  WoL is configured through the Ethtool* utility.  Ethtool is included with
-  all versions of Red Hat after Red Hat 7.2.  For other Linux distributions,
-  download and install Ethtool from the following website:
-  http://sourceforge.net/projects/gkernel.
-
-  For instructions on enabling WoL with Ethtool, refer to the website listed
-  above.
+  WoL is configured through the Ethtool* utility.
 
   WoL will be enabled on the system during the next shut down or reboot.
   For this driver version, in order to enable WoL, the e1000 driver must be
   loaded when shutting down or rebooting the system.
 
-  Wake On LAN is only supported on port A for the following devices:
-  Intel(R) PRO/1000 PT Dual Port Network Connection
-  Intel(R) PRO/1000 PT Dual Port Server Connection
-  Intel(R) PRO/1000 PT Dual Port Server Adapter
-  Intel(R) PRO/1000 PF Dual Port Server Adapter
-  Intel(R) PRO/1000 PT Quad Port Server Adapter
-
-  NAPI
-  ----
-  NAPI (Rx polling mode) is enabled in the e1000 driver.
-
-  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
-
-
-Known Issues
-============
-
-Dropped Receive Packets on Half-duplex 10/100 Networks
-------------------------------------------------------
-If you have an Intel PCI Express adapter running at 10mbps or 100mbps, half-
-duplex, you may observe occasional dropped receive packets.  There are no
-workarounds for this problem in this network configuration.  The network must
-be updated to operate in full-duplex, and/or 1000mbps only.
-
-Jumbo Frames System Requirement
--------------------------------
-Memory allocation failures have been observed on Linux systems with 64 MB
-of RAM or less that are running Jumbo Frames.  If you are using Jumbo
-Frames, your system may require more than the advertised minimum
-requirement of 64 MB of system memory.
-
-Performance Degradation with Jumbo Frames
------------------------------------------
-Degradation in throughput performance may be observed in some Jumbo frames
-environments.  If this is observed, increasing the application's socket
-buffer size and/or increasing the /proc/sys/net/ipv4/tcp_*mem entry values
-may help.  See the specific application manual and
-/usr/src/linux*/Documentation/
-networking/ip-sysctl.txt for more details.
-
-Jumbo Frames on Foundry BigIron 8000 switch
--------------------------------------------
-There is a known issue using Jumbo frames when connected to a Foundry
-BigIron 8000 switch.  This is a 3rd party limitation.  If you experience
-loss of packets, lower the MTU size.
-
-Allocating Rx Buffers when Using Jumbo Frames 
----------------------------------------------
-Allocating Rx buffers when using Jumbo Frames on 2.6.x kernels may fail if 
-the available memory is heavily fragmented. This issue may be seen with PCI-X 
-adapters or with packet split disabled. This can be reduced or eliminated 
-by changing the amount of available memory for receive buffer allocation, by
-increasing /proc/sys/vm/min_free_kbytes. 
-
-Multiple Interfaces on Same Ethernet Broadcast Network
-------------------------------------------------------
-Due to the default ARP behavior on Linux, it is not possible to have
-one system on two IP networks in the same Ethernet broadcast domain
-(non-partitioned switch) behave as expected.  All Ethernet interfaces
-will respond to IP traffic for any IP address assigned to the system.
-This results in unbalanced receive traffic.
-
-If you have multiple interfaces in a server, either turn on ARP
-filtering by entering:
-
-    echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
-(this only works if your kernel's version is higher than 2.4.5),
-
-NOTE: This setting is not saved across reboots.  The configuration
-change can be made permanent by adding the line:
-    net.ipv4.conf.all.arp_filter = 1
-to the file /etc/sysctl.conf
-
-      or,
-
-install the interfaces in separate broadcast domains (either in
-different switches or in a switch partitioned to VLANs).
-
-82541/82547 can't link or are slow to link with some link partners
------------------------------------------------------------------
-There is a known compatibility issue with 82541/82547 and some
-low-end switches where the link will not be established, or will
-be slow to establish.  In particular, these switches are known to
-be incompatible with 82541/82547:
-
-    Planex FXG-08TE
-    I-O Data ETG-SH8
-
-To workaround this issue, the driver can be compiled with an override
-of the PHY's master/slave setting.  Forcing master or forcing slave
-mode will improve time-to-link.
-
-    # make CFLAGS_EXTRA=-DE1000_MASTER_SLAVE=<n>
-
-Where <n> is:
-
-    0 = Hardware default
-    1 = Master mode
-    2 = Slave mode
-    3 = Auto master/slave
-
-Disable rx flow control with ethtool
-------------------------------------
-In order to disable receive flow control using ethtool, you must turn
-off auto-negotiation on the same command line.
-
-For example:
-
-   ethtool -A eth? autoneg off rx off
-
-Unplugging network cable while ethtool -p is running
-----------------------------------------------------
-In kernel versions 2.5.50 and later (including 2.6 kernel), unplugging
-the network cable while ethtool -p is running will cause the system to
-become unresponsive to keyboard commands, except for control-alt-delete.
-Restarting the system appears to be the only remedy.
-
-
 Support
 =======
 

