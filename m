From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2.5 1/3] e1000: Configuration and user guide update
Date: Mon, 18 Oct 2004 03:22:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410180259060.20965-100000@isotope.jf.intel.com>
References: <Pine.LNX.4.44.0410150515070.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150515070.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -Nuarp old/Documentation/networking/e1000.txt new/Documentation/networking/e1000.txt
--- old/Documentation/networking/e1000.txt	2004-10-07 15:50:44.000000000 -0700
+++ new/Documentation/networking/e1000.txt	2004-10-07 15:51:15.000000000 -0700
@@ -1,14 +1,14 @@
 Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
 ===============================================================
 
-January 8, 2003
+September 13, 2004
 
 
 Contents
 ========
 
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
 - Command Line Parameters
 - Speed and Duplex Configuration
 - Additional Configurations
@@ -20,63 +20,29 @@ In This Release
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/1000 Family
-of Adapters, version 5.0.x.  This driver includes support for 
-Itanium(TM)-based systems.
+of Adapters, version 5.x.x.  This driver includes support for Itanium(TM)2 
+and EM64T systems.
 
+For questions related to hardware requirements, refer to the documentation 
+supplied with your Intel PRO/1000 adapter. All hardware requirements listed 
+apply to use with Linux.
 
 Native VLANs are now available with supported kernels.
 
-
-Supported Adapters
-==================
-
-The following Intel network adapters are compatible with the drivers in this 
-release:
-
-   Controller  Adapter Name                         Board IDs
-   ----------  ------------                         ---------
-
-   82542       PRO/1000 Gigabit Server Adapter      700262-xxx, 717037-xxx
-
-   82543       PRO/1000 F Server Adapter            738640-xxx, A38888-xxx
-
-   82543       PRO/1000 T Server Adapter            A19845-xxx, A33948-xxx
-
-   82544       PRO/1000 XT Server Adapter           A51580-xxx
-
-   82544       PRO/1000 XF Server Adapter           A50484-xxx
-
-   82544       PRO/1000 T Desktop Adapter           A62947-xxx
-
-   82540       PRO/1000 MT Desktop Adapter          A78408-xxx
-   82541                                            C91016-xxx
-
-   82545       PRO/1000 MT Server Adapter           A92165-xxx
-
-   82546       PRO/1000 MT Dual Port Server Adapter A92111-xxx
-
-   82545       PRO/1000 MF Server Adapter           A91622-xxx
-
-   82545       PRO/1000 MF Server Adapter(LX)       A91624-xxx
-
-   82546       PRO/1000 MF Dual Port Server Adapter A91620-xxx
-
-
-
-To verify your Intel adapter is supported, find the board ID number on the 
-adapter. Look for a label that has a barcode and a number in the format  
-A12345-001. Match this to the list of numbers above.
+Identifying Your Adapter
+========================
 
 For more information on how to identify your adapter, go to the Adapter & 
 Driver ID Guide at:
 
     http://support.intel.com/support/network/adapter/pro100/21397.htm
 
-For the latest Intel network drivers for Linux, refer to the following
+For the latest Intel network drivers for Linux, refer to the following 
+website. In the search field, enter your adapter name or type, or use the 
+networking link on the left to search for your adapter:
 
     http://downloadfinder.intel.com/scripts-df/support_intel.asp
 
-
 Command Line Parameters
 =======================
 
@@ -92,27 +58,39 @@ For example, with two PRO/1000 PCI adapt
 
      insmod e1000 TxDescriptors=80,128
 
-loads the e1000 driver with 80 TX resources for the first adapter and 128 TX 
-resources for the second adapter.
+loads the e1000 driver with 80 TX descriptors for the first adapter and 128 TX 
+descriptors for the second adapter.
 
 The default value for each parameter is generally the recommended setting,
-unless otherwise noted.
-
-For more information about the AutoNeg, Duplex, and Speed parameters, see the
-"Speed and Duplex Configuration" section in this document.
+unless otherwise noted. Also, if the driver is statically built into the
+kernel, the driver is loaded with the default values for all the parameters.
+Ethtool can be used to change some of the parameters at runtime.
+
+    NOTES: For more information about the AutoNeg, Duplex, and Speed
+           parameters, see the "Speed and Duplex Configuration" section in 
+           this document.
+
+           For more information about the InterruptThrottleRate, RxIntDelay, 
+           TxIntDelay, RxAbsIntDelay, and TxAbsIntDelay parameters, see the 
+           application note at:
+           http://www.intel.com/design/network/applnots/ap450.htm
 
+           A descriptor describes a data buffer and attributes related to the 
+           data buffer. This information is accessed by the hardware.
 
 AutoNeg (adapters using copper connections only)
 Valid Range: 0x01-0x0F, 0x20-0x2F
 Default Value: 0x2F
     This parameter is a bit mask that specifies which speed and duplex
     settings the board advertises. When this parameter is used, the Speed and
-    Duplex parameters must not be specified.  
+    Duplex parameters must not be specified.
+    NOTE: Refer to the Speed and Duplex section of this readme for more 
+          information on the AutoNeg parameter.  
 
 Duplex (adapters using copper connections only)
 Valid Range: 0-2 (0=auto-negotiate, 1=half, 2=full)
 Default Value: 0
-    Defines the direction in which data is allowed to flow. Can by either one 
+    Defines the direction in which data is allowed to flow. Can be either one 
     or two-directional. If both Duplex and the link partner are set to auto-
     negotiate, the board auto-detects the correct duplex. If the link partner
     is forced (either full or half), Duplex defaults to half-duplex.
@@ -125,22 +103,46 @@ Default: Read flow control settings from
 
 InterruptThrottleRate
 Valid Range: 100-100000 (0=off, 1=dynamic)
-Default Value: 1
+Default Value: 8000
     This value represents the maximum number of interrupts per second the 
     controller generates. InterruptThrottleRate is another setting used in 
     interrupt moderation. Dynamic mode uses a heuristic algorithm to adjust 
     InterruptThrottleRate based on the current traffic load.
+Un-supported Adapters: InterruptThrottleRate is NOT supported by 82542, 82543
+    or 82544-based adapters.
 
     NOTE: InterruptThrottleRate takes precedence over the TxAbsIntDelay and 
           RxAbsIntDelay parameters. In other words, minimizing the receive 
           and/or transmit absolute delays does not force the controller to 
           generate more interrupts than what the Interrupt Throttle Rate 
           allows.
+    CAUTION: If you are using the Intel PRO/1000 CT Network Connection 
+             (controller 82547), setting InterruptThrottleRate to a value 
+             greater than 75,000, may hang (stop transmitting) adapters under 
+             certain network conditions. If this occurs a NETDEV WATCHDOG 
+             message is logged in the system event log. In addition, the 
+             controller is automatically reset, restoring the network 
+             connection. To eliminate the potential for the hang, ensure 
+             that InterruptThrottleRate is set no greater than 75,000 and is 
+             not set to 0.
+    NOTE: When e1000 is loaded with default settings and multiple adapters are 
+          in use simultaneously, the CPU utilization may increase non-linearly. 
+          In order to limit the CPU utilization without impacting the overall 
+          throughput, we recommend that you load the driver as follows:
+
+              insmod e1000.o InterruptThrottleRate=3000,3000,3000
+
+          This sets the InterruptThrottleRate to 3000 interrupts/sec for the 
+          first, second, and third instances of the driver. The range of 2000 to 
+          3000 interrupts per second works on a majority of systems and is a 
+          good starting point, but the optimal value will be platform-specific. 
+          If CPU utilization is not a concern, use RX_POLLING (NAPI) and default 
+          driver settings.
 
 RxDescriptors
 Valid Range: 80-256 for 82542 and 82543-based adapters
-             80-4096 for 82540, 82544, 82545, and 82546-based adapters
-Default Value: 80
+             80-4096 for all other supported adapters
+Default Value: 256
     This value is the number of receive descriptors allocated by the driver. 
     Increasing this value allows the driver to buffer more incoming packets. 
     Each descriptor is 16 bytes.  A receive buffer is also allocated for each
@@ -149,6 +151,9 @@ Default Value: 80
 
     NOTE: MTU designates the frame size. It only needs to be set for Jumbo 
           Frames.
+    NOTE: Depending on the available system resources, the request for a
+    higher number of receive descriptors may be denied.  In this case,
+    use a lower number.
 
 RxIntDelay
 Valid Range: 0-65535 (0=off)
@@ -168,11 +173,11 @@ Default Value: 0
              restoring the network connection. To eliminate the potential for
              the hang ensure that RxIntDelay is set to 0.
 
-RxAbsIntDelay (82540, 82545, and 82546-based adapters only)
+RxAbsIntDelay (82540, 82545 and later adapters only)
 Valid Range: 0-65535 (0=off)
 Default Value: 128
     This value, in units of 1.024 microseconds, limits the delay in which a 
-    transmit interrupt is generated. Useful only if RxIntDelay is non-zero, 
+    receive interrupt is generated. Useful only if RxIntDelay is non-zero, 
     this value ensures that an interrupt is generated after the initial 
     packet is received within the set amount of time.  Proper tuning,
     along with RxIntDelay, may improve traffic throughput in specific network
@@ -188,12 +193,16 @@ Default Value: 0 (auto-negotiate at all 
 
 TxDescriptors
 Valid Range: 80-256 for 82542 and 82543-based adapters
-             80-4096 for 82540, 82544, 82545, and 82546-based adapters
+             80-4096 for all other supported adapters
 Default Value: 256
     This value is the number of transmit descriptors allocated by the driver.
     Increasing this value allows the driver to queue more transmits. Each 
     descriptor is 16 bytes.
 
+    NOTE: Depending on the available system resources, the request for a
+    higher number of transmit descriptors may be denied.  In this case,
+    use a lower number.
+
 TxIntDelay
 Valid Range: 0-65535 (0=off)
 Default Value: 64
@@ -203,7 +212,7 @@ Default Value: 64
     system is reporting dropped transmits, this value may be set too high
     causing the driver to run out of available transmit descriptors.
 
-TxAbsIntDelay (82540, 82545, and 82546-based adapters only)
+TxAbsIntDelay (82540, 82545 and later adapters only)
 Valid Range: 0-65535 (0=off)
 Default Value: 64
     This value, in units of 1.024 microseconds, limits the delay in which a 
@@ -219,7 +228,6 @@ Default Value: 1
     A value of '1' indicates that the driver should enable IP checksum
     offload for received packets (both UDP and TCP) to the adapter hardware.
 
-
 Speed and Duplex Configuration
 ==============================
 
@@ -251,6 +259,10 @@ Bit            7      6      5       4  
 Speed (Mbps)   N/A    N/A    1000    N/A     100    100    10      10
 Duplex                       Full            Full   Half   Full    Half
 
+For example to limit the negotiated speed/duplex on the interface to 10 Mbps 
+Half or Full duplex, set AutoNeg to 0x02: 
+    insmod e1000 AutoNeg=0x02
+
 Note that setting AutoNeg does not guarantee that the board will link at the 
 highest specified speed or duplex mode, but the board will link at the 
 highest possible speed/duplex of the link partner IF the link partner is also
@@ -261,6 +273,38 @@ adapter MUST be forced to the same speed
 Additional Configurations
 =========================
 
+  Configuring the Driver on Different Distributions
+  -------------------------------------------------
+
+  Configuring a network driver to load properly when the system is started is
+  distribution dependent. Typically, the configuration process involves adding
+  an alias line to /etc/modules.conf as well as editing other system startup 
+  scripts and/or configuration files. Many popular Linux distributions ship 
+  with tools to make these changes for you. To learn the proper way to 
+  configure a network device for your system, refer to your distribution 
+  documentation. If during this process you are asked for the driver or module 
+  name, the name for the Linux Base Driver for the Intel PRO/1000 Family of 
+  Adapters is e1000.
+
+  As an example, if you install the e1000 driver for two PRO/1000 adapters 
+  (eth0 and eth1) and set the speed and duplex to 10full and 100half, add the 
+  following to modules.conf:
+
+       alias eth0 e1000
+       alias eth1 e1000
+       options e1000 Speed=10,100 Duplex=2,1
+
+  Viewing Link Messages
+  ---------------------
+
+  Link messages will not be displayed to the console if the distribution is 
+  restricting system messages. In order to see network driver link messages on 
+  your console, set dmesg to eight by entering the following:
+
+       dmesg -n 8
+
+  NOTE: This setting is not saved across reboots.
+
   Jumbo Frames
   ------------
 
@@ -278,6 +322,51 @@ Additional Configurations
   10 or 100 Mbps may result in poor performance or loss of link.
 
 
+  NOTE: MTU designates the frame size. To enable Jumbo Frames, increase the
+  MTU size on the interface beyond 1500.
+
+  Ethtool
+  -------
+
+  The driver utilizes the ethtool interface for driver configuration and
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 1.6 or later is required for this functionality.
+
+  The latest release of ethtool can be found from
+  http://sf.net/projects/gkernel.  After ethtool is installed,
+  ethtool-copy.h must be copied and renamed to ethtool.h in your kernel
+  source tree at <linux_kernel_src>/include/linux.  Backup the original
+  ethtool.h as needed before copying.  The driver then must be recompiled
+  in order to take advantage of the latest ethtool features.
+
+  NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Support 
+  for a more complete ethtool feature set can be enabled by upgrading 
+  ethtool to ethtool-1.8.1. 
+
+  Enabling Wake on LAN* (WoL)
+  ---------------------------
+
+  WoL is configured through the Ethtool* utility. Ethtool is included with
+  all versions of Red Hat after Red Hat 7.2. For other Linux distributions, 
+  download and install Ethtool from the following website: 
+  http://sourceforge.net/projects/gkernel.
+
+  For instructions on enabling WoL with Ethtool, refer to the website listed 
+  above.
+
+  WoL will be enabled on the system during the next shut down or reboot. 
+  For this driver version, in order to enable WoL, the e1000 driver must be 
+  loaded when shutting down or rebooting the system.
+
+  NAPI
+  ----
+
+  NAPI (Rx polling mode) is supported in the e1000 driver. NAPI is enabled
+  or disabled based on the configuration of the kernel. 
+
+  See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
+
+
 Known Issues
 ============
 
@@ -285,9 +374,9 @@ Known Issues
   -------------------------------
 
   Memory allocation failures have been observed on Linux systems with 64 MB 
-  of RAM or less that are running Jumbo Frames. If you are using Jumbo 
-  Frames, your system may require more than the advertised minimum 
-  requirement of 64 MB of system memory.
+  of RAM or less that are running Jumbo Frames. If you are using Jumbo Frames,
+  your system may require more than the advertised minimum requirement of 64 MB
+  of system memory.
 
 
 Support
diff -Nuarp old/drivers/net/Kconfig new/drivers/net/Kconfig
--- old/drivers/net/Kconfig	2004-10-07 15:52:11.000000000 -0700
+++ new/drivers/net/Kconfig	2004-10-07 15:52:27.000000000 -0700
@@ -1933,29 +1933,8 @@ config E1000
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-	  adapters, which includes:
-
-	  Controller  Adapter Name                         Board IDs
-	  ----------  ------------                         ---------
-	  82542       PRO/1000 Gigabit Server Adapter      700262-xxx,
-	  717037-xxx
-	  82543       PRO/1000 F Server Adapter            738640-xxx,
-	  A38888-xxx
-	  82543       PRO/1000 T Server Adapter            A19845-xxx,
-	  A33948-xxx
-	  82544       PRO/1000 XT Server Adapter           A51580-xxx
-	  82544       PRO/1000 XF Server Adapter           A50484-xxx
-	  82544       PRO/1000 T Desktop Adapter           A62947-xxx
-	  82540       PRO/1000 MT Desktop Adapter          A78408-xxx
-	  82541       PRO/1000 MT Desktop Adapter          C91016-xxx
-	  82545       PRO/1000 MT Server Adapter           A92165-xxx
-	  82546       PRO/1000 MT Dual Port Server Adapter A92111-xxx
-	  82545       PRO/1000 MF Server Adapter           A91622-xxx
-	  82545       PRO/1000 MF Server Adapter(LX)       A91624-xxx
-	  82546       PRO/1000 MF Dual Port Server Adapter A91620-xxx 
-
-	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide at:
+	  adapters.  For more information on how to identify your adapter, go 
+	  to the Adapter & Driver ID Guide at:
 
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
 
