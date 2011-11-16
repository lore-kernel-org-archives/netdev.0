From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network Kconfig options
Date: Wed, 16 Nov 2011 14:15:09 -0800
Message-ID: <c7e7b57596f9a06b1c40c8b6e671cc6ac69dd304.1321481064.git.david.decotigny@google.com>
References: <cover.1321481064.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:49161 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab1KPWPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:15:37 -0500
Received: by wwe5 with SMTP id 5so24575wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 14:15:36 -0800 (PST)
In-Reply-To: <cover.1321481064.git.david.decotigny@google.com>
In-Reply-To: <cover.1321481064.git.david.decotigny@google.com>
References: <cover.1321481064.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a description of RPS/XPS options and allow them to be
changed at make menuconfig time.

It also fixes following checkpatch syntax warnings:
ERROR: trailing whitespace
+^I  $

ERROR: trailing whitespace
+^I$



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 net/Kconfig |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index a073148..8e2104e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -10,7 +10,7 @@ menuconfig NET
 	  The reason is that some programs need kernel networking support even
 	  when running on a stand-alone machine that isn't connected to any
 	  other computer.
-	  
+
 	  If you are upgrading from an older kernel, you
 	  should consider updating your networking tools too because changes
 	  in the kernel and the tools often go hand in hand. The tools are
@@ -217,20 +217,33 @@ source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 
 config RPS
-	boolean
+	boolean "Enable Receive Packet Steering"
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
+	help
+	  RPS distributes the load of received packet processing
+	  across multiple CPUs. If unsure, say Y.
 
 config RFS_ACCEL
-	boolean
+	boolean "Enable Hardware Acceleration of RFS"
 	depends on RPS && GENERIC_HARDIRQS
 	select CPU_RMAP
 	default y
+	help
+	  This is the hardware version of RPS. On multi-queue network
+	  devices, this configures the hardware to distribute the
+	  received packets across multiple CPUs. If unsure, say Y.
 
 config XPS
-	boolean
+	boolean "Enable Transmit Packet Steering"
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
+	help
+	  For multiqueue devices, XPS selects a transmit queue during
+	  packet transmission based on configuration. This is done by
+	  mapping the CPU transmitting the packet to a queue. XPS can
+	  reduce transmit network latency on SMP systems. If unsure,
+	  say Y.
 
 config HAVE_BPF_JIT
 	bool
@@ -274,7 +287,6 @@ config NET_TCPPROBE
 
 	Documentation on how to use TCP connection probing can be found
 	at:
-	
 	  http://www.linuxfoundation.org/collaborate/workgroups/networking/tcpprobe
 
 	To compile this code as a module, choose M here: the
-- 
1.7.3.1
