From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [PATCH] hamradio/scc -
Date: Tue, 16 Sep 2003 22:53:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916225353.I13088@jeroen.pe1rxq.ampr.org>
References: <20030915162335.0034a551.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com,
   Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030915162335.0034a551.shemminger@osdl.org>; from shemminger@osdl.org on Tue, Sep 16, 2003 at 01:23:35 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

On 2003.09.16 01:23:35 +0200 Stephen Hemminger wrote:
> Update hamradio/scc for 2.6.0-test5
> 	- use seq_file for /proc
> 	- get rid of dev_get()
> 	- use alloc_netdev

I have a little adition of my own (should apply nicely next to this patch).
The probe function uses the not yet initialized scc struct for requesting
its io region.

The second patch is against the bpqethernet driver.
This has a debug printk that seems to be untouched since somewhere early
2.1 kernels.
The if statement it debugs seems to work perfectly and its only use at the
moment is to annoy the hell out of me :)

Jeroen

--AWniW0JNca5xppdA
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

--AWniW0JNca5xppdA
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
 

--AWniW0JNca5xppdA--
