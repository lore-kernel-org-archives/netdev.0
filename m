From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] igb.txt: Add igb documentation
Date: Tue, 03 Aug 2010 17:15:54 -0700
Message-ID: <20100804001429.6571.95116.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:44435
	"EHLO qmta01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757955Ab0HDAQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 20:16:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for the igb networking driver.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
---

 Documentation/networking/igb.txt |  134 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/igb.txt

diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
new file mode 100644
index 0000000..975023a
--- /dev/null
+++ b/Documentation/networking/igb.txt
@@ -0,0 +1,134 @@
+Linux* Base Driver for Intel(R) Network Connection
+==================================================
+
+Intel Gigabit Linux driver.
+Copyright(c) 1999 - 2010 Intel Corporation.
+
+Contents
+========
+
+- Identifying Your Adapter
+- Additional Configurations
+- Support
+
+Identifying Your Adapter
+========================
+
+This driver supports all 82575, 82576 and 82580-based Intel (R) gigabit network
+connections.
+
+For specific information on how to identify your adapter, go to the Adapter &
+Driver ID Guide at:
+
+    http://support.intel.com/support/go/network/adapter/idguide.htm
+
+Command Line Parameters
+=======================
+
+The default value for each parameter is generally the recommended setting,
+unless otherwise noted.
+ 
+max_vfs
+-------
+Valid Range:   0-7
+Default Value: 0
+
+This parameter adds support for SR-IOV.  It causes the driver to spawn up to 
+max_vfs worth of virtual function.  
+
+Additional Configurations
+=========================
+
+  Jumbo Frames
+  ------------
+  Jumbo Frames support is enabled by changing the MTU to a value larger than
+  the default of 1500.  Use the ifconfig command to increase the MTU size.
+  For example:
+
+       ifconfig eth<x> mtu 9000 up
+
+  This setting is not saved across reboots.  
+
+  Notes:
+
+  - The maximum MTU setting for Jumbo Frames is 9216.  This value coincides
+    with the maximum Jumbo Frames size of 9234 bytes.
+
+  - Using Jumbo Frames at 10 or 100 Mbps may result in poor performance or
+    loss of link.
+
+  Ethtool
+  -------
+  The driver utilizes the ethtool interface for driver configuration and
+  diagnostics, as well as displaying statistical information.  Ethtool
+  version 3.0 or later is required for this functionality, although we 
+  strongly recommend downloading the latest version at:
+
+  http://sourceforge.net/projects/gkernel.
+
+  Enabling Wake on LAN* (WoL)
+  ---------------------------
+  WoL is configured through the Ethtool* utility. 
+
+  For instructions on enabling WoL with Ethtool, refer to the Ethtool man page.
+
+  WoL will be enabled on the system during the next shut down or reboot.
+  For this driver version, in order to enable WoL, the igb driver must be
+  loaded when shutting down or rebooting the system.
+
+  Wake On LAN is only supported on port A of multi-port adapters.
+
+  Wake On LAN is not supported for the Intel(R) Gigabit VT Quad Port Server 
+  Adapter.
+
+  Multiqueue
+  ----------
+  In this mode, a separate MSI-X vector is allocated for each queue and one
+  for "other" interrupts such as link status change and errors.  All 
+  interrupts are throttled via interrupt moderation.  Interrupt moderation 
+  must be used to avoid interrupt storms while the driver is processing one 
+  interrupt.  The moderation value should be at least as large as the expected
+  time for the driver to process an interrupt. Multiqueue is off by default.
+
+  REQUIREMENTS: MSI-X support is required for Multiqueue. If MSI-X is not 
+  found, the system will fallback to MSI or to Legacy interrupts.
+
+  LRO
+  ---
+  Large Receive Offload (LRO) is a technique for increasing inbound throughput
+  of high-bandwidth network connections by reducing CPU overhead. It works by
+  aggregating multiple incoming packets from a single stream into a larger 
+  buffer before they are passed higher up the networking stack, thus reducing
+  the number of packets that have to be processed. LRO combines multiple 
+  Ethernet frames into a single receive in the stack, thereby potentially 
+  decreasing CPU utilization for receives.
+
+  NOTE: LRO requires 2.6.24 or later kernel version. You also need to have
+  inet_lro enabled via either the CONFIG_INET_LRO or CONFIG_INET_LRO_MODULE 
+  kernel config option. Additionally, if CONFIG_INET_LRO_MODULE is used, the
+  inet_lro module needs to be loaded before the igb driver.
+
+  You can verify that the driver is using LRO by looking at these counters in 
+  Ethtool:
+
+  lro_aggregated - count of total packets that were combined
+  lro_flushed - counts the number of packets flushed out of LRO
+  lro_no_desc - counts the number of times an LRO descriptor was not available 
+  for the LRO packet
+
+  NOTE: IPv6 and UDP are not supported by LRO.
+
+Support
+=======
+
+For general information, go to the Intel support website at:
+
+    www.intel.com/support/
+
+or the Intel Wired Networking project hosted by Sourceforge at:
+
+    http://sourceforge.net/projects/e1000
+
+If an issue is identified with the released source code on the supported
+kernel with a supported adapter, email the specific information related
+to the issue to e1000-devel@lists.sf.net

