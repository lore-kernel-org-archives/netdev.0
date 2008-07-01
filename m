From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] ipv4: fix sysctl documentation of time related values
Date: Tue, 1 Jul 2008 15:39:26 -0700
Message-ID: <20080701153926.7b3fe1dd@extreme>
References: <20080701153820.235faa72@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48746 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763325AbYGAWnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:43:18 -0400
In-Reply-To: <20080701153820.235faa72@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These sysctl values are time related and all use the same routine
(proc_dointvec_jiffies) that internally converts from seconds to jiffies.
The code is fine, the documentation is just wrong.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/Documentation/networking/ip-sysctl.txt	2008-07-01 14:45:30.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-07-01 14:45:56.000000000 -0700
@@ -81,23 +81,23 @@ inet_peer_minttl - INTEGER
 	Minimum time-to-live of entries.  Should be enough to cover fragment
 	time-to-live on the reassembling side.  This minimum time-to-live  is
 	guaranteed if the pool size is less than inet_peer_threshold.
-	Measured in jiffies(1).
+	Measured in seconds.
 
 inet_peer_maxttl - INTEGER
 	Maximum time-to-live of entries.  Unused entries will expire after
 	this period of time if there is no memory pressure on the pool (i.e.
 	when the number of entries in the pool is very small).
-	Measured in jiffies(1).
+	Measured in seconds.
 
 inet_peer_gc_mintime - INTEGER
 	Minimum interval between garbage collection passes.  This interval is
 	in effect under high memory pressure on the pool.
-	Measured in jiffies(1).
+	Measured in seconds.
 
 inet_peer_gc_maxtime - INTEGER
 	Minimum interval between garbage collection passes.  This interval is
 	in effect under low (or absent) memory pressure on the pool.
-	Measured in jiffies(1).
+	Measured in seconds.
 
 TCP variables: 
 
@@ -795,10 +795,6 @@ tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
 
-(1) Jiffie: internal timeunit for the kernel. On the i386 1/100s, on the
-Alpha 1/1024s. See the HZ define in /usr/include/asm/param.h for the exact
-value on your system. 
-
 Alexey Kuznetsov.
 kuznet@ms2.inr.ac.ru
 
