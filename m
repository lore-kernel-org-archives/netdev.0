From: Andi Kleen <ak@suse.de>
Subject: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Wed, 30 Jan 2008 09:38:49 +0100 (CET)
Message-ID: <20080130938.523292915@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:39561 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820AbYA3IzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:55:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We've recently had a long discussion about the CVE-2005-0356 time stamp denial-of-service
attack. It turned out that Linux is only vunerable to this problem when tcp_tw_recycle
is enabled (which it is not by default).

In general these two options are not really usable in today's internet because they
make the (often false) assumption that a single IP address has a single TCP time stamp /
PAWS clock. This assumption breaks both NAT/masquerading and also opens Linux to denial
of service attacks (see the CVE description) 

Due to these numerous problems I propose to remove this code for 2.6.26

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/Documentation/feature-removal-schedule.txt
===================================================================
--- linux.orig/Documentation/feature-removal-schedule.txt
+++ linux/Documentation/feature-removal-schedule.txt
@@ -354,3 +354,15 @@ Why:	The support code for the old firmwa
 	and slightly hurts runtime performance. Bugfixes for the old firmware
 	are not provided by Broadcom anymore.
 Who:	Michael Buesch <mb@bu3sch.de>
+
+---------------------------
+
+What:   Support for /proc/sys/net/ipv4/tcp_tw_{reuse,recycle} = 1
+When:   2.6.26
+Why:    Enabling either of those makes Linux TCP incompatible with masquerading and
+        also opens Linux to the CVE-2005-0356 denial of service attack.  And these
+        optimizations are explicitely disallowed by some benchmarks. They also have
+        been disabled by default for more than ten years so they're unlikely to be used
+	much. Due to these fatal flaws it doesn't make sense to keep the code.
+Who:    Andi Kleen <andi@firstfloor.org>
+
