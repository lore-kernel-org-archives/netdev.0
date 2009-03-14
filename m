From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 1/10] Neterion: New driver: Driver help file
Date: 14 Mar 2009 00:20:42 -0800
Message-ID: <1237018830.4966.414.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60408 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbZCNHxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- vxge driver help text file.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/Documentation/networking/vxge.txt patch_1/Documentation/networking/vxge.txt
--- org/Documentation/networking/vxge.txt	1969-12-31 16:00:00.000000000 -0800
+++ patch_1/Documentation/networking/vxge.txt	2009-03-12 11:23:12.000000000 -0700
@@ -0,0 +1,476 @@
+Release notes for Neterion's (Formerly S2io) X3100 Linux Driver.
+
+contents
+--------
+
+1) Introduction
+2) Load/Unload Neterion driver
+3) Identifying the adapter/interface
+4) Features supported
+5) Configurable driver parameters
+6) Performance Suggestions
+7) Transmit performance
+8) Receive performance
+9) Troubleshooting
+10) Ethtool Support
+11) Known Issues
+12) Common Problems
+13) Available Downloads
+
+1) Introduction:
+----------------
+Linux Driver for Neterion 10 Gigabit Ethernet PCI Express I/O Virtualized Server Adapter
+
+ * This driver supports all Neterion's X3100 10GbE adapters and 2.4.x and 2.6.x kernels.
+ * Supports several features such as jumbo frames, MSI-X, checksum offloads, TSO, LRO and so on.
+(See below for complete list of features supported for both IPv4 and IPv6)
+
+2) Load/Unload Neterion driver:
+-------------------------------
+
+i). Load driver
+     For 2.4 kernel
+       # insmod /lib/modules/<kernel_version>/kernel/drivers/net/vxge.o
+     For 2.6 kernel
+       # insmod /lib/modules/<kernel_version>/kernel/drivers/net/vxge.ko
+     Using modprobe command:
+	# modprobe vxge
+
+     Verify driver loaded using lsmod
+       # lsmod |grep vxge
+
+ii). Configure IP address
+     ifconfig eth# <IP_address> up
+       # ifconfig eth1 17.1.1.100 up
+
+iii). Modify MTU
+     ifconfig eth# mtu <new_mtu>
+       # ifconfig eth1 mtu 9000
+
+iv). Unload driver
+       # ifconfig eth# down
+       # rmmod vxge
+
+3) Identifying the adapter/interface:
+-------------------------------------
+
+i). Insert the adapter(s) in your system.
+
+ii). Load driver
+     # insmod  /lib/modules/<kernel_version>/kernel/drivers/net/vxge.ko
+
+     Using modprobe command:
+	# modprobe vxge
+
+iii). View log messages
+     # dmesg | tail -40
+
+   Messages similar to the following will output which identify the adapter
+   type, adapter revision, driver version, interface number, and interrupt type:
+
+   eth2: Neterion 10 Gigabit Ethernet X3110 Rev (2)
+   eth2: MAC ADDR: 00:0C:FC:00:B2:53 SERIAL NUMBER: SXJ0839036
+   eth2: Firmware version: 0.0.34 Date : 12/02/2008
+   eth2: Driver version: v.1.0.0 kernel version 2.6.16
+   eth2: Build time: Nov 25 2008, 23:19:49
+   eth2: 8 Vpath(s) enabled
+   eth2: Interrupt type MSI-X
+   eth2: RTH steering enabled for TCP_IPV4
+   eth2: Tx port steering enabled
+   eth2: Large receive offload enabled
+   eth2: Multiqueue support disabled
+   eth2: VLAN tag stripping disabled
+   eth2: NAPI disabled
+   eth2: Ring blocks : 2
+   eth2: Fifo blocks : 12
+
+iv). To associate an interface with a physical adapter use "ethtool -p eth#".
+   The corresponding adapter's LED will blink until canceled (ctrl+c).
+
+
+4) Features supported:
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
+       Large Receive Offload (LRO, TCP aggregation) on receive path
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
+5) Configurable driver parameters:
+----------------------------------
+
+i) intr_type
+	Specifies interrupt type.
+	Valid range: 0, 2 (INTA, MSI-X respectively)
+	Default: 2
+
+ii) lro
+	Enables/disables Large Receive Offload (LRO).
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 1
+
+iii) lro_max_bytes
+	Specifies maximum number of bytes to be aggregated as
+	a single large packet.
+	Valid range: 0-FFFF
+	Default: 0x4000
+
+iv) max_config_dev
+	Specifies maximum device functions to be enabled.
+	Valid range: 1-8
+	Default:
+
+v) max_config_port:
+	Specifies number of ports to be enabled.
+	Valid range: 0,1
+	Default: 1
+
+vi) max_config_vpath:
+	Specifies maximum VPATH(s) configured for each device function.
+	Valid range: 1-17
+	Default:
+
+vii) napi
+	Enables/disables NAPI support.
+	Automatically disabled when intr_type is set to MSI-X on kernels below
+	2.6.24.
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 1
+
+viii) rpa_strip_vlan_tag
+	Enables/disables vlan tag stripping from all received tagged frames that
+	are not replicated at the internal L2 switch.
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 1
+
+ix) tx_steering_type
+	Specifies criteria for steering transmitted packets.
+	Valid range: 0-4 (disabled, priority, VLAN ID, multiq and L4 port respectively)
+	Default: 4
+
+The following parameters are used collectively to enable the receive
+traffic steering capability of the driver.
+
+x) addr_learn_en
+	Enable Receive Traffic Steering using MAC destination address.
+	Valid range: 0,1 (disabled, enabled respectively)
+	Default: 0
+
+xi) rx_steering_type
+	Specifies criteria for steering received packets.
+	Valid range: 0-4 (disabled, L4 port, RTH, priority and VLAN ID respectively)
+	Default: 2 (when system supports MSI-X and has more than 4 CPUs)
+
+xii) ring_indicate_max_pkts
+	Sets maximum number of received frames to be processed within single interrupt.
+	Valid range: 1 - 65536
+	Default : 128
+
+xiii) fifo_indicate_max_pkts:
+	Sets maximum number of transmit frames to be processed within single interrupt.
+	Valid range: 1 - 65536
+	Default : 32
+
+xiv) ring_blocks:
+	Numbers of RxD blocks in the ring
+	Valid range: 1 - 128
+	Default : 2
+
+xv) Boot time configuration
+	In order to load option(s) at boot time, add the option(s) to
+	/etc/modprobe.conf.
+	Example:
+		alias eth# vxge
+		options vxge rx_blocks=4 rx_steering_type=2
+
+
+6) Performance Suggestions:
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
+7) Transmit performance:
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
+8) Receive performance:
+-----------------------
+
+- Ensure Receive Checksum offload is enabled. Use ethtool to verify/set.
+	# ethtool -k eth#
+	# ethtool -K eth# rx on
+
+- If MTU is set to 1500, receive performance can be improved by increasing
+  the default TCP window size and enabling LRO (see "Configurable driver
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
+9) Troubleshooting:
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
+
+Before Contacting Neterion for Support:
+
+i) Please contact your network adapter provider (i.e. OEM or reseller) for
+   initial support.
+
+ii) Run the titanl_dump utility which is included in the linux driver package on
+    Nterion's driver downloads page.
+	# titanl_dump eth#
+
+iii) When contacting Neterion for support, please include the following in
+     your email to support@neterion.com:
+	- The titanl_dump.log.gz file resulting from step 2 above
+	- Brief description of your setup and how you are using
+	  your X3100 adapter
+
+
+
+10) Ethtool Support:
+--------------------
+Ethtool is useful for driver configuration, diagnostics and displaying
+statistical information.  The latest version of Ethtool is available at
+http://sourceforge.net/projects/gkernel/
+
+	ethtool eth#
+		Displays current device settings
+
+	ethtool -a eth#
+		Displays pause parameter information.
+
+	ethtool -A eth#
+		Changes pause parameters.
+
+	ethtool -d eth#
+		Retrieves and prints a register dump for the specified
+		ethernet device.
+
+	ethtool -e eth# [raw on|off] [offset N] [length N]
+		Retrieves and prints an EEPROM dump for the specified
+		ethernet device.  When raw is enabled, then it dumps the raw
+		EEPROM data to stdout. The length and offset parameters allow
+		dumping certain portions of the EEPROM.  Default is to dump
+		the entire EEPROM.
+
+	ethtool -E eth# [magic N] [offset N] [value N]
+		Changes  EEPROM  byte for the specified ethernet device.
+		Offset and value specify which byte and its new value.
+		Because of the persistent nature of writing to the EEPROM, a
+		device-specific magic key must be specified to prevent the
+		accidental writing to the EEPROM.
+
+	ethtool -g ethx
+		Queries the specified ethernet device for rx/tx
+		ring parameter information.
+
+	ethtool -i eth#
+		Displays device driver information
+
+	ethtool -k eth#
+		Displays offload parameters information.
+
+	ethtool -K eth# [rx on|off] [tx on|off] [sg on|off] [tso on|off]
+		Changes offload parameters.
+		 rx - RX checksum offload
+		 tx - TX checksum offload
+		 sg - scatter-gather
+		 tso - TCP Segmentation Offload
+
+	ethtool -p eth# [N]
+		Initiates adapter-specific action intended to enable an
+		operator to easily identify the physical adapter by sight.
+		Typically this involves blinking one or more LEDs on the
+		specified ethernet port.
+
+		 N - Length of time to perform phys-id, in seconds.
+
+	ethtool -S eth#
+		Displays adapter and driver statistics.
+
+	ethtool -t eth# [offline|online]
+		Executes adapter selftest on the specified ethernet device.
+		Possible test modes are:
+
+		offline (default) - performs full set of tests, possibly
+		interrupting normal adapter operation during the tests.
+		online - performs limited set of tests, not interrupting normal
+		adapter operation.
+
+11) Known Issues:
+-----------------
+i) TSO disabled in SUSE 9:
+	TSO is disabled by default in SuSE 9. It may be manually enabled
+	using the ethtool command.
+		# ethtool -K eth# tso on
+
+12) Common Problems:
+--------------------
+
+i) Symbolic link:
+	Before debugging any compilation related problems, ensure that the
+	following symbolic link/directory points to the correct kernel source
+	tree.
+		For 2.4, /usr/src/linux-2.4
+		For 2.6, /usr/src/linux-2.6
+
+ii) Version Mismatch:
+	One of the common problems encountered on trying to load the driver is
+	related to a version mismatch between current kernel and the kernel for
+	which the driver was built. Typical error message is as follows:
+
+	Using /lib/modules/2.x.y-SMP/kernel/drivers/net/vxge.o
+	/lib/modules/2.x.y-SMP/kernel/drivers/net/vxge.o: kernel-module
+	version mismatch /lib/modules/2.x.y-SMP/kernel/drivers/net/vxge.o
+	was compiled for kernel version 2.x.y while this kernel is version
+	2.x.y-SMP.
+
+	To fix this problem, ensure the kernel is enabled for SMP by following
+	these steps:
+
+		- Go to the directory where kernel sources are located.
+		  (e.g. /usr/src/linux-2.4.19.SuSE)
+
+		- Execute "make menuconfig". This will bring up the "Linux
+		  Kernel Configuration" menu. Select "Processor type
+		  and features". Ensure that "Symmetric multi-processing
+		  support" is enabled.
+		  Save this configuration and exit.
+
+	This will compile the kernel with SMP support.
+
+13) Available Downloads:
+------------------------
+
+	For latest available Neterion drivers or further support please
+	contact your network adapter provider or check the Neterion support
+	download site at
+	http://www.neterion.com/support/xframe_customers.html
+
+	This readme applies to the Neterion Linux driver available from our
+	website. Although the Neterion Linux drivers are included in the
+	mainline kernel and major Linux distributions (i.e. Red Hat, Suse, etc),
+	and are similar, each distribution accepts or rejects our driver changes
+	at their own discretion. Therefore, some features may be enabled or
+	disabled in different releases.
+
+===============================================================================
+ Neterion Inc. Proprietary
+ COPYRIGHT (c) 2002-2009 Neterion Inc, ALL RIGHTS RESERVED
+



