From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: possible bug in net/core/pktgen.c (2.6.10 kernel)
Date: Sun, 16 Jan 2005 13:46:50 +0100
Message-ID: <16874.25146.335366.990655@robur.slu.se>
References: <200501141129.21461.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Peterson <dsp@llnl.gov>
In-Reply-To: <200501141129.21461.dsp@llnl.gov>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dave Peterson writes:

 > I found a piece of code that looks problematic in the 2.6.10 kernel.
 > The following code appears starting on line 746 in function inject()
 > of net/core/pktgen.c:
 >                                         schedule();
 >                                 else
 >                                         do_softirq();


 Thanks! 
 So it should be?

--- net/core/pktgen.c.orig	2005-01-16 13:39:10.933427120 +0100
+++ net/core/pktgen.c	2005-01-16 13:40:41.926751672 +0100
@@ -753,8 +753,11 @@
 				}
 				if (need_resched())
 					schedule();
-				else
+				else {
+					preempt_disable();
 					do_softirq();
+					preempt_enable();
+				}
 			} while (netif_queue_stopped(odev));
 			idle = cycles() - idle_start;
 			info->idle_acc += idle;



						--ro
