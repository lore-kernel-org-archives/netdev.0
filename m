From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: [PATCH] (resend)
Date: Wed, 8 Oct 2003 23:56:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008235634.C207@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+fexcqMh/evT6CrY"
Content-Transfer-Encoding: 8bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+fexcqMh/evT6CrY
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Hi,

These patches don't seem to have made it into the mainstream kernel yet....
Can you please apply them?

The first is a fix for the probe function of the scc driver which now uses
an uninitialised scc struct for requesting an io region.
The Second removes a verry old debug line from the bpqethernet driver that
only fills logs.

Thanks,
Jeroen

--+fexcqMh/evT6CrY
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="scc-2.6.0.t5.rxq.diff"

--- linux-2.6.0-test5/drivers/net/hamradio/scc.c	Mon Sep  8 21:50:22 2003
+++ linux-2.6.0-test5.rxq/drivers/net/hamradio/scc.c	Tue Sep 16 22:41:36 2003
@@ -1767,7 +1767,7 @@
 
 #ifndef SCC_DONT_CHECK
 
-			if(request_region(scc->ctrl, 1, "scc-probe"))
+			if(request_region(hwcfg.ctrl_a, 1, "scc-probe"))
 			{
 				disable_irq(hwcfg.irq);
 				Outb(hwcfg.ctrl_a, 0);
@@ -1779,7 +1779,7 @@
 				if (InReg(hwcfg.ctrl_a,R13) != 0x55)
 					found = 0;
 				enable_irq(hwcfg.irq);
-				release_region(scc->ctrl, 1);
+				release_region(hwcfg.ctrl_a, 1);
 			}
 			else
 				found = 0;

--+fexcqMh/evT6CrY
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="bpqether-2.6.0.t5.rxq.diff"

--- linux-2.6.0-test5/drivers/net/hamradio/bpqether.c	Mon Sep  8 21:50:03 2003
+++ linux-2.6.0-test5.rxq/drivers/net/hamradio/bpqether.c	Mon Sep 15 15:40:16 2003
@@ -189,10 +189,8 @@
 
 	bpq = (struct bpqdev *)dev->priv;
 
-	if (!(bpq->acpt_addr[0] & 0x01) && memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN)) {
-		printk(KERN_DEBUG "bpqether: wrong dest %s\n", bpq_print_ethaddr(eth->h_source));
+	if (!(bpq->acpt_addr[0] & 0x01) && memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN))
 		goto drop;
-	}
 
 	len = skb->data[0] + skb->data[1] * 256 - 5;
 

--+fexcqMh/evT6CrY--
