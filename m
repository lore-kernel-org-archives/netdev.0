From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Fw: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP
Date: Fri, 3 Oct 2003 16:10:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16253.33625.541433.36206@robur.slu.se>
References: <20030929123734.5bd97a47.akpm@osdl.org>
	<16248.41796.797321.700866@robur.slu.se>
	<3F78A691.1040406@pobox.com>
	<16252.17618.866515.952549@robur.slu.se>
	<3F7C64BC.7030701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Andrew Morton <akpm@osdl.org>,
        netdev@oss.sgi.com, dfages@arkoon.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F7C64BC.7030701@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff Garzik writes:
 > 
 > Looks great to me.  I'll give it some testing here, and 99% likely will 
 > apply it.
 > 
 > Andrew, would you be willing to merge this into -mm for some 
 > simultaneous netwide testing?

 Fine!

 Here is a additional patch to active disable poll so we don't have to wait in
 dev_close() for traffic to disappear.

 Cheers.
						--ro

--- drivers/net/tulip/interrupt.c.03103	2001-11-03 18:52:54.000000000 +0100
+++ drivers/net/tulip/interrupt.c	2003-10-03 13:21:46.000000000 +0200
@@ -116,6 +116,8 @@
 	tp->stats_poll_starts++;
 #endif
 
+	if(!netif_running(dev)) goto done;
+
 	if (rx_work_limit > dev->quota)
 		rx_work_limit = dev->quota;
 
@@ -241,7 +243,7 @@
 		 * finally: amount of IO did not increase at all. */
 	} while ((inl(dev->base_addr + CSR5) & RxIntr));
 
-/* done: */
+done: 
 
 
 #ifdef USE_MITIGATION
