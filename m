From: linux@horizon.com
Subject: Re: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: 8 Jan 2008 01:52:11 -0500
Message-ID: <20080108065211.25290.qmail@science.horizon.com>
References: <20070930022347.37514be3.akpm@linux-foundation.org>
Cc: linux@horizon.com
To: akpm@linux-foundation.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:14883 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752858AbYAHGwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:52:13 -0500
In-Reply-To: <20070930022347.37514be3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to keep the issue open, drivers/net/ipg.c currently in 2.6.24-rc6
still leaks skbuffs like a sieve.  Run it for a few hours with network
traffic and the machine swaps like crazy while the oom killer goes nuts.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..4fa392c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -172,6 +172,10 @@ config IP1000
 	select MII
 	---help---
 	  This driver supports IP1000 gigabit Ethernet cards.
+	  It works, but suffers from a memory leak.  Signifcant
+	  use will consume unswappable kernel memory until the
+	  machine runs out of memory and crashes.  Thus, this
+	  driver cannot be considered usable at the the present time.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.

Or should it be demoted to BROKEN?  It compiles, and sends and receives
packets, which is better than a lot of BROKEN drivers.
