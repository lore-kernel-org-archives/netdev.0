From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 1/9] Neterion: Driver help file
Date: 27 Mar 2009 14:54:08 -0800
Message-ID: <1238194447.5516.374.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:35500 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbZC0WJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- vxge driver help text file.
- Changes in this submission -
 - Removed tx/rx_pause, exec_mode, tx_steering_type, rx_steering_type, gro, 
   intr_type, rx & tx max_indicate_pkts and exec_mode loadable parameters. The
   driver default settings work well in most if not all cases. Another patch 
   to configure these parameters with ethtool will be released in the future -
   Reported by Stephen Hemminger.

- Changes in the last submission -
- Incorporated following fixes based on comments from Ben Hutchings
	Removed references to earlier kernel versions.
	Removed sections that are similar for all drivers -
		Load/Unload
		Identifying the adapter/interface
		Boot time configuration
	Removed loadable parameter -
		NAPI - Napi is always enabled.
		rx_steering_type & ring_blocks - The driver default settings
		work well in most if not all cases. Another patch to configure
		these parameters with ethtool will be released in the future.
	Removed ethtool support section - No need to duplicate ethtool
		docs here.
	Removed Known Issue on SUSE 9 - Doesn't apply when using a
		current kernel.
	Removed Common Problems section - These don't apply to in-tree modules.
	Removed Available Downloads section - Not sure this belongs in-tree.
	Removed Copyright information - This notice doesn't belong in
		the kernel.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/Documentation/networking/vxge.txt patch_1/Documentation/networking/vxge.txt
--- org/Documentation/networking/vxge.txt	1969-12-31 16:00:00.000000000 -0800
+++ patch_1/Documentation/networking/vxge.txt	2009-03-27 00:35:00.000000000 -0700
@@ -0,0 +1,199 @@
+Release notes for Neterion's (Formerly S2io) X3100 Linux Driver.
+
+contents
+--------
+
+1) Introduction
+2) Features supported
+3) Configurable driver parameters
+4) Performance Suggestions
+5) Transmit performance
+6) Receive performance
+7) Troubleshooting
+
+1) Introduction:
+----------------
+Linux Driver for Neterion 10 Gigabit Ethernet PCI Express I/O Virtualized Server Adapter
+
+ * This driver supports all Neterion's X3100 10GbE adapters.
+ * Supports several features such as jumbo frames, MSI-X, checksum offloads, TSO, GRO and so on.
+(See below for complete list of features supported for both IPv4 and IPv6)
+
+2) Features supported:
+----------------------
+
+i) I/O Virtualization Offloads:
+	- Single function mode
+	- Multi function mode
+
+ii) PCI-SIG's I/O Virtualization:
+	- Single Root mode: v1.0
+	- Multi-Root mode: v1.0
+
+iii) Jumbo frames:
+	X3100 Series supports MTU up to 9600 bytes, modifiable using
+	ifconfig command.
+
+iv) Offloads supported:
+       Checksum offload (TCP/UDP/IP) on transmit and receive paths
+       TCP Segmentation Offload (TSO) on transmit path
+       Generic Receive Offload (GRO) on receive path
+
+v) MSI-X:
+	Can be enabled on platforms which support it, resulting in noticeable
+	performance improvement (up to 7% on certain platforms).
+
+vi) NAPI:
+	For better Rx interrupt moderation.
+
+vii) RTH (Receive Traffic Hash):
+	Receive side steering for better scaling.
+
+viii) Statistics:
+	Comprehensive MAC-level and software statistics displayed using
+	"ethtool -S" option.
+
+ix) Multi-Vpaths:
+	Up to 17 hardware based transmit and receive data channels, with
+	multiple steering options.
+
+
+3) Configurable driver parameters:
+----------------------------------
+
+i) max_config_dev
+	Specifies maximum device functions to be enabled.
+	Valid range: 1-8
+
+ii) max_config_port:
+	Specifies number of ports to be enabled.
+	Valid range: 0,1
+	Default: 1
+
+iii) max_config_vpath:
+	Specifies maximum VPATH(s) configured for each device function.
+	Valid range: 1-17
+
+iv) vlan_tag_strip
+	Enables/disables vlan tag stripping from all received tagged frames that
+	are not replicated at the internal L2 switch.
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 1
+
+v) addr_learn_en
+	Enable learning the mac address of the guest OS interface in
+	virtualization environment.
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 0
+
+4) Performance Suggestions:
+---------------------------
+
+- Set MTU to maximum - 9000 for switch setup, 9600 for back-to-back.
+For MTU 1500:
+-------------
+### IPV4 specific settings
+# turns TCP timestamp support off, default 1, reduces CPU use
+$sysctl -w net.ipv4.tcp_timestamps = "0"
+# turn SACK support off, default on
+$sysctl -w net.ipv4.tcp_sack="0"
+# on systems with a VERY fast bus -> memory interface this is the big gainer
+# sets min/default/max TCP read buffer, default 4096 87380 174760
+$sysctl -w net.ipv4.tcp_rmem="210000 210000 210000"
+# sets min/pressure/max TCP write buffer, default 4096 16384 131072
+$sysctl -w net.ipv4.tcp_wmem="210000 210000 210000"
+# sets min/pressure/max TCP buffer space, default 31744 32256 32768
+$sysctl -w net.ipv4.tcp_mem="210000 210000 210000"
+
+### CORE settings (mostly for socket and UDP effect)
+# maximum receive socket buffer size, default 131071
+$sysctl -w net.core.rmem_max="524287"
+# maximum send socket buffer size, default 131071
+$sysctl -w net.core.wmem_max="524287"
+# default receive socket buffer size, default 65535
+$sysctl -w net.core.rmem_default="524287"
+# default send socket buffer size, default 65535
+$sysctl -w net.core.wmem_default="524287"
+# maximum amount of option memory buffers, default 10240
+$sysctl -w net.core.optmem_max="524287"
+# number of unprocessed input packets before kernel starts dropping them, default 300
+$sysctl -w net.core.netdev_max_backlog="300000"
+
+For MTU 9000:
+-------------
+### IPV4 specific settings
+# turns TCP timestamp support off, default 1, reduces CPU use
+$sysctl -w net.ipv4.tcp_timestamps = "0"
+# turn SACK support off, default on
+$sysctl -w net.ipv4.tcp_sack="0"
+# on systems with a VERY fast bus -> memory interface this is the big gainer
+# sets min/default/max TCP read buffer, default 4096 87380 174760
+$sysctl -w net.ipv4.tcp_rmem="10000000 10000000 10000000"
+# sets min/pressure/max TCP write buffer, default 4096 16384 131072
+$sysctl -w net.ipv4.tcp_wmem="10000000 10000000 10000000"
+# sets min/pressure/max TCP buffer space, default 31744 32256 32768
+$sysctl -w net.ipv4.tcp_mem="10000000 10000000 10000000"
+
+### CORE settings (mostly for socket and UDP effect)
+# maximum receive socket buffer size, default 131071
+$sysctl -w net.core.rmem_max="524287"
+# maximum send socket buffer size, default 131071
+$sysctl -w net.core.wmem_max="524287"
+# default receive socket buffer size, default 65535
+$sysctl -w net.core.rmem_default="524287"
+# default send socket buffer size, default 65535
+$sysctl -w net.core.wmem_default="524287"
+# maximum amount of option memory buffers, default 10240
+$sysctl -w net.core.optmem_max="524287"
+# number of unprocessed input packets before kernel starts dropping them, default 300
+$sysctl -w net.core.netdev_max_backlog="300000"
+
+5) Transmit performance:
+------------------------
+
+- Ensure Transmit Checksum offload and TSO are enabled.
+  Use ethtool to verify/set these parameters.
+
+	# ethtool -k eth#
+	Offload parameters for eth0:
+	rx-checksumming: on
+	tx-checksumming: on
+	scatter-gather: on
+	tcp segmentation offload: off
+
+- Turn on Transmit Checksum offload and TSO:
+	# ethtool -K eth# tx on
+	# ethtool -K eth# tso on (for 2.6 kernels)
+
+
+6) Receive performance:
+-----------------------
+
+- Ensure Receive Checksum offload is enabled. Use ethtool to verify/set.
+	# ethtool -k eth#
+	# ethtool -K eth# rx on
+
+- If MTU is set to 1500, receive performance can be improved by increasing
+  the default TCP window size and enabling GRO (see "Configurable driver
+  parameters" section).
+	# sysctl -p sysctl_neterion_1500.conf
+
+- Enable NAPI to bring down CPU utilization.
+
+- If CPU bottleneck is being hit (close to 0% idle), you can play around with
+  utilization parameters by using tune_driver script. This may help bring
+  down CPU utilization and improve throughput. See "Driver tuning" section.
+
+
+7) Troubleshooting:
+-------------------
+
+For X3100 adapter assigned eth2
+
+Statistics Dump:
+	# ethtool -S eth2
+
+Register Dump:
+	# ethtool -d eth2
+
+===============================================================================



