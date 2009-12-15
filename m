From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 3/4] net: port mirroring: add config options to
	enable port mirroring
Date: Tue, 15 Dec 2009 11:38:40 -0500
Message-ID: <20091215163840.GE18710@hmsreliant.think-freely.org>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56893 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbZLOQin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:38:43 -0500
Content-Disposition: inline
In-Reply-To: <20091215162956.GB18710@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add configuration to enable port mirroring feature.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 Kconfig       |   14 ++++++++++++++
 core/Makefile |    1 +
 2 files changed, 15 insertions(+)

diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..b94f950 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -246,6 +246,20 @@ config NET_DROP_MONITOR
 	just checking the various proc files and other utilities for
 	drop statistics, say N here.
 
+config NET_PORT_MIRRORING
+	boolean "Network port mirroring"
+	depends on EXPERIMENTAL && TRACEPOINTS
+	---help---
+	When debugging network connectivity problems, it can be useful (and
+	sometimes necessecary) to record frames from an interface without using
+	any of the systems under test (e.g. if running a capture on the system
+	in question affects it in such a way that the problem then cannot be 
+	reproduced).  Port mirroring allows for the traffic to and from a given
+	port to be resent unaltered to a secondary port, so that a tertiary
+	system can record the traffic).  If you need to be able to see monitor
+	network traffic to/from a system without running software on the system
+	in question, say Y here.
+
 endmenu
 
 endmenu
diff --git a/net/core/Makefile b/net/core/Makefile
index 08791ac..305d88d 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -18,4 +18,5 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
+obj-$(CONFIG_NET_PORT_MIRRORING) += mirror.o
 
