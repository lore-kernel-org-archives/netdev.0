From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 1/9] Neterion: Driver help file
Date: 01 Apr 2009 20:14:23 -0800
Message-ID: <1238645631.18544.211.camel@flash>
References: <1238194447.5516.374.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33616 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758354AbZDBDcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:32:47 -0400
In-Reply-To: <1238194447.5516.374.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- vxge driver help text file.

- No change from previous submission.

- Changes in previous submissions -
  Removed the performance tuning section with instructions to disable
  time stamps and change sysctl settings - Reported by Dave Miller
  General clean up.
 - Removed tx/rx_pause, exec_mode, tx_steering_type, rx_steering_type, gro,
   intr_type, rx & tx max_indicate_pkts and exec_mode loadable parameters. The
   driver default settings work well in most if not all cases. Another patch
   to configure these parameters with ethtool will be released in the future -
   Reported by Stephen Hemminger.
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
+++ patch_1/Documentation/networking/vxge.txt	2009-03-31 16:10:16.000000000 -0700
@@ -0,0 +1,100 @@
+Neterion's (Formerly S2io) X3100 Series 10GbE PCIe Server Adapter Linux driver
+==============================================================================
+
+Contents
+--------
+
+1) Introduction
+2) Features supported
+3) Configurable driver parameters
+4) Troubleshooting
+
+1) Introduction:
+----------------
+This Linux driver supports all Neterion's X3100 series 10 GbE PCIe I/O
+Virtualized Server adapters.
+The X3100 series supports four modes of operation, configurable via
+firmware -
+	Single function mode
+	Multi function mode
+	SRIOV mode
+	MRIOV mode
+The functions share a 10GbE link and the pci-e bus, but hardly anything else
+inside the ASIC. Features like independent hw reset, statistics, bandwidth/
+priority allocation and guarantees, GRO, TSO, interrupt moderation etc are
+supported independently on each function.
+
+(See below for a complete list of features supported for both IPv4 and IPv6)
+
+2) Features supported:
+----------------------
+
+i)   Single function mode (up to 17 queues)
+
+ii)  Multi function mode (up to 17 functions)
+
+iii) PCI-SIG's I/O Virtualization
+       - Single Root mode: v1.0 (up to 17 functions)
+       - Multi-Root mode: v1.0 (up to 17 functions)
+
+iv)  Jumbo frames
+       X3100 Series supports MTU up to 9600 bytes, modifiable using
+       ifconfig command.
+
+v)   Offloads supported: (Enabled by default)
+       Checksum offload (TCP/UDP/IP) on transmit and receive paths
+       TCP Segmentation Offload (TSO) on transmit path
+       Generic Receive Offload (GRO) on receive path
+
+vi)  MSI-X: (Enabled by default)
+       Resulting in noticeable performance improvement (up to 7% on certain
+       platforms).
+
+vii) NAPI: (Enabled by default)
+       For better Rx interrupt moderation.
+
+viii)RTH (Receive Traffic Hash): (Enabled by default)
+       Receive side steering for better scaling.
+
+ix)  Statistics
+       Comprehensive MAC-level and software statistics displayed using
+       "ethtool -S" option.
+
+x)   Multiple hardware queues: (Enabled by default)
+       Up to 17 hardware based transmit and receive data channels, with
+       multiple steering options (transmit multiqueue enabled by default).
+
+3) Configurable driver parameters:
+----------------------------------
+
+i)  max_config_dev
+       Specifies maximum device functions to be enabled.
+       Valid range: 1-8
+
+ii) max_config_port
+       Specifies number of ports to be enabled.
+       Valid range: 1,2
+       Default: 1
+
+iii)max_config_vpath
+       Specifies maximum VPATH(s) configured for each device function.
+       Valid range: 1-17
+
+iv) vlan_tag_strip
+       Enables/disables vlan tag stripping from all received tagged frames that
+       are not replicated at the internal L2 switch.
+       Valid range: 0,1 (disabled, enabled respectively)
+       Default: 1
+
+v)  addr_learn_en
+       Enable learning the mac address of the guest OS interface in
+       virtualization environment.
+       Valid range: 0,1 (disabled, enabled respectively)
+       Default: 0
+
+4) Troubleshooting:
+-------------------
+
+To resolve an issue with the source code or X3100 series adapter, please collect
+the statistics, register dumps using ethool, relevant logs and email them to
+support@neterion.com.



