From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/3 2.5] e100: Configuration and user guide update
Date: Fri, 15 Oct 2004 06:50:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150519580.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp old/linux-2.5/Documentation/networking/e100.txt new/linux-2.5/Documentation/networking/e100.txt
--- old/linux-2.5/Documentation/networking/e100.txt	2004-10-07 15:50:39.000000000 -0700
+++ new/linux-2.5/Documentation/networking/e100.txt	2004-10-07 15:51:33.000000000 -0700
@@ -1,14 +1,16 @@
 Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
 ==============================================================
 
-March 15, 2004
+September 13, 2004
 
 
 Contents
 ========
 
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
+- Driver Configuration Parameters
+- Additional Configurations
 - Support
 
 
@@ -16,26 +18,140 @@ In This Release
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/100 Family of
-Adapters, version 3.x.x.  This driver includes support for Itanium(TM)-based 
-systems.
+Adapters, version 3.2.x.  This driver includes support for Itanium(TM)2 and
+EM64T systems.
 
 
-Supported Adapters
-==================
-
-To verify that your adapter is supported, find the board ID number on the 
-adapter. Look for a label that has a barcode and a number in the format 
-A12345-001. Match this to the list of numbers above.
+Identifying Your Adapter
+========================
 
 For more information on how to identify your adapter, go to the Adapter & 
 Driver ID Guide at:
 
   http://support.intel.com/support/network/adapter/pro100/21397.htm
 
-For the latest Intel PRO/100 network driver for Linux, see:
+For the latest Intel network drivers for Linux, refer to the following 
+website. In the search field, enter your adapter name or type, or use the 
+networking link on the left to search for your adapter:
 
   http://downloadfinder.intel.com/scripts-df/support_intel.asp
 
+Driver Configuration Parameters
+===============================
+
+The default value for each parameter is generally the recommended setting,
+unless otherwise noted.
+
+Rx Descriptors: Number of receive descriptors. A receive descriptor is a data 
+   structure that describes a receive buffer and its attributes to the network 
+   controller. The data in the descriptor is used by the controller to write 
+   data from the controller to host memory. In the 3.0.x driver the valid
+   range for this parameter is 64-256. The default value is 64. This parameter 
+   can be changed using the command 
+ 
+   ethtool -G eth? rx n, where n is the number of desired rx descriptors.
+
+Tx Descriptors: Number of transmit descriptors. A transmit descriptor is a
+   data structure that describes a transmit buffer and its attributes to the
+   network controller. The data in the descriptor is used by the controller to 
+   read data from the host memory to the controller. In the 3.0.x driver the 
+   valid range for this parameter is 64-256. The default value is 64. This 
+   parameter can be changed using the command 
+
+   ethtool -G eth? tx n, where n is the number of desired tx descriptors.
+
+Speed/Duplex: The driver auto-negotiates the link speed and duplex settings by 
+   default. Ethtool can be used as follows to force speed/duplex. 
+
+   ethtool -s eth?  autoneg off speed {10|100} duplex {full|half}
+
+   NOTE: setting the speed/duplex to incorrect values will cause the link to
+   fail.
+
+Event Log Message Level:  The driver uses the message level flag to log events 
+   to syslog. The message level can be set at driver load time. It can also be 
+   set using the command
+
+   ethtool -s eth? msglvl n
+
+Additional Configurations
+=========================
+
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+
+  Configuring a network driver to load properly when the system is started is 
+  distribution dependent. Typically, the configuration process involves adding 
+  an alias line to /etc/modules.conf as well as editing other system startup 
+  scripts and/or configuration files.  Many popular Linux distributions ship 
+  with tools to make these changes for you. To learn the proper way to 
+  configure a network device for your system, refer to your distribution 
+  documentation. If during this process you are asked for the driver or module 
+  name, the name for the Linux Base Driver for the Intel PRO/100 Family of 
+  Adapters is e100.
+
+  As an example, if you install the e100 driver for two PRO/100 adapters 
+  (eth0 and eth1), add the following to modules.conf:
+
+       alias eth0 e100
+       alias eth1 e100
+
+  Viewing Link Messages
+  ---------------------
+  In order to see link messages and other Intel driver information on your 
+  console, you must set the dmesg level up to six. This can be done by 
+  entering the following on the command line before loading the e100 driver: 
+
+       dmesg -n 8
+
+  If you wish to see all messages issued by the driver, including debug 
+  messages, set the dmesg level to eight.
+
+  NOTE: This setting is not saved across reboots.
+
+  Ethtool
+  -------
+
+  The driver utilizes the ethtool interface for driver configuration and
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found at:
+  http://sf.net/projects/gkernel.  
+
+  After ethtool is installed, ethtool-copy.h must be copied and renamed to
+  ethtool.h in your kernel source tree at <linux_kernel_src>/include/linux.  
+  Backup the original ethtool.h as needed before copying.  The driver then 
+  must be recompiled in order to take advantage of the latest ethtool 
+  features.
+
+  NOTE: This driver uses mii support from the kernel. As a result, when 
+  there is no link, ethtool will report speed/duplex to be 10/half.
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Support 
+  for a more complete ethtool feature set can be enabled by upgrading 
+  ethtool to ethtool-1.8.1. 
+
+  Enabling Wake on LAN* (WoL)
+  ---------------------------
+  WoL is provided through the Ethtool* utility. Ethtool is included with Red 
+  Hat* 8.0. For other Linux distributions, download and install Ethtool from 
+  the following website: http://sourceforge.net/projects/gkernel. 
+
+  For instructions on enabling WoL with Ethtool, refer to the Ethtool man
+  page.
+
+  WoL will be enabled on the system during the next shut down or reboot. For
+  this driver version, in order to enable WoL, the e100 driver must be 
+  loaded when shutting down or rebooting the system.
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the e100 driver. NAPI is enabled
+  or disabled based on the configuration of the kernel. 
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
 
 Support
 =======
diff -Nuarp old/linux-2.5/drivers/net/Kconfig new/linux-2.5/drivers/net/Kconfig
--- old/linux-2.5/drivers/net/Kconfig	2004-10-07 15:52:11.000000000 -0700
+++ new/linux-2.5/drivers/net/Kconfig	2004-10-07 15:52:27.000000000 -0700
@@ -1413,66 +1413,17 @@ config E100
 	depends on NET_PCI && PCI
 	select MII
 	---help---
-	  This driver supports Intel(R) PRO/100 family of adapters, which 
-	  includes:
-
-	  Controller  Adapter Name                       Board IDs
-	  ----------  ------------                       ---------
-
-	  82558       PRO/100+ PCI Adapter               668081-xxx, 
-	  689661-xxx
-	  82558       PRO/100+ Management Adapter        691334-xxx, 
-	  701738-xxx,
-	  721383-xxx
-	  82558       PRO/100+ Dual Port Server Adapter  714303-xxx, 
-	  711269-xxx, 
-	  A28276-xxx
-	  82558       PRO/100+ PCI Server Adapter        710550-xxx
-	  82550       PRO/100 S Server Adapter           752438-xxx
-	  82559                                          A56831-xxx, 
-	  A10563-xxx,
-	  A12171-xxx, 
-	  A12321-xxx, 
-	  A12320-xxx, 
-	  A12170-xxx
-	  748568-xxx
-	  748565-xxx
-	  82550       PRO/100 S Desktop Adapter          751767-xxx
-	  82559                                          748592-xxx, 
-	  A12167-xxx, 
-	  A12318-xxx, 
-	  A12317-xxx, 
-	  A12165-xxx,
-	  748569-xxx 
-	  82559       PRO/100+ Server Adapter            729757-xxx
-	  82559       PRO/100 S Management Adapter       748566-xxx, 
-	  748564-xxx
-	  82550       PRO/100 S Dual Port Server Adapter A56831-xxx
-	  82551       PRO/100 M Desktop Adapter          A80897-xxx
-	  PRO/100 S Advanced Management Adapter 
-	  747842-xxx, 
-	  745171-xxx
-	  CNR         PRO/100 VE Desktop Adapter         A10386-xxx, 
-	  A10725-xxx, 
-	  A23801-xxx, 
-	  A19716-xxx
-	  PRO/100 VM Desktop Adapter         A14323-xxx, 
-	  A19725-xxx, 
-	  A23801-xxx, 
-	  A22220-xxx, 
-	  A23796-xxx
-
-
+	  This driver supports Intel(R) PRO/100 family of adapters.
 	  To verify that your adapter is supported, find the board ID number 
 	  on the adapter. Look for a label that has a barcode and a number 
-	  in the format 123456-001 (six digits hyphen three digits). Match 
-	  this to the list of numbers above.
+	  in the format 123456-001 (six digits hyphen three digits). 
 
-	  For more information on how to identify your adapter, go to the 
-	  Adapter & Driver ID Guide at:
+	  Use the above information and the Adapter & Driver ID Guide at:
 
 	  http://support.intel.com/support/network/adapter/pro100/21397.htm
 
+          to identify the adapter.
+
 	  For the latest Intel PRO/100 network driver for Linux, see:
 
 	  http://appsr.intel.com/scripts-df/support_intel.asp
