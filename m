From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon,  5 Mar 2012 22:38:16 -0500
Message-ID: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51437 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757361Ab2CFDiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 22:38:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without the defining string or help text, LKC won't ever bother
to ask the end user for a setting for CONFIG_BQL -- you could
delete it from your .config and run make oldconfig and not a
thing would change -- it would still be silently re-enabled.

While most people will have no reason to turn this off, the
ability to do so can be useful for testing BQL support additions
on previously BQL-unaware drivers and similar.

The kconfig help text is largely taken from the original RFC
patchset 0/N header sent to netdev@vger.kernel.org in fall 2011.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Apologies if this was explicitly blocked for a reason; I couldn't
 find a reason after searching netdev or threads at bufferbloat.net ]

diff --git a/net/Kconfig b/net/Kconfig
index e07272d..fd1d815 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -241,10 +241,15 @@ config NETPRIO_CGROUP
 	  a per-interface basis
 
 config BQL
-	boolean
+	boolean	"Byte Queue Limits"
 	depends on SYSFS
 	select DQL
 	default y
+	---help---
+	  Byte queue limits are a mechanism to limit the size of the transmit
+	  hardware queue on a NIC by a number of bytes. The goal of these byte
+	  queue limits is to reduce latency caused by excessive queuing in
+	  hardware without sacrificing throughput.
 
 config HAVE_BPF_JIT
 	bool
-- 
1.7.9.1
