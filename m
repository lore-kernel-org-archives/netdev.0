From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] net: Add ftracer to help optimize process
	scheduling based on incomming frame allocations (v2)
Date: Sat, 8 Aug 2009 19:15:00 -0400
Message-ID: <20090808231500.GC24414@localhost.localdomain>
References: <20090807202130.GA26677@hmsreliant.think-freely.org> <20090808231322.GA24414@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rostedt@goodmis.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49954 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbZHHXPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 19:15:05 -0400
Content-Disposition: inline
In-Reply-To: <20090808231322.GA24414@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb allocation / consumption corelator - Add config option

This patch adds a Kconfig option to enable the addtition of the skb source
tracer.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 1551f47..1aeec05 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -234,6 +234,16 @@ config BOOT_TRACER
 	  You must pass in ftrace=initcall to the kernel command line
 	  to enable this on bootup.
 
+config SKB_SOURCES_TRACER
+	bool "Trace skb source information
+	select GENERIC_TRACER
+	help
+	   This tracer helps developers/sysadmins correlate skb allocation and
+	   consumption.  The idea being that some processes will primarily consume data
+	   that was allocated on certain numa nodes.  By being able to visualize which
+	   nodes the data was allocated on, a sysadmin or developer can optimize the
+	   scheduling of those processes to cut back on cross node chatter.
+
 config TRACE_BRANCH_PROFILING
 	bool
 	select GENERIC_TRACER
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

