From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 04 Jan 2005 22:19:29 -0500
Message-ID: <1104895169.1117.63.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0846Th3rEGC6QKddUtsg"
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41DB26A6.2070008@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-0846Th3rEGC6QKddUtsg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-01-04 at 18:28, Jeff Garzik wrote:
> jamal wrote:
> > The change is simple if theres consensus to go this path.
> 
> Can you resend your patch?

I didnt send any patch - but heres one that looks right - havent tried
compiling it.

> My main objection was that any change should be made in the core, not in 
> individual net drivers.

Attached patch resolves that concern

> Another objection was that it seemed that some of the proposed solutions 
> for clearing the queue on link down were imposing app-specific policy on 
> the overall kernel.
>
> Aren't there cases where people would -not- want the queue to be cleared?

Thats a good question and your point of imposing policy in the kernel is
valid. I know that i would probably want packets to appear they are
going out when the wire is pulled from underneath me.
Theres possibly people who would want it differently - so for we havent
heard from them. Maybe poll far and wide - or push it in and wait for
them to whine.

cheers,
jamal

--=-0846Th3rEGC6QKddUtsg
Content-Disposition: attachment; filename=nc.p
Content-Type: text/plain; name=nc.p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2610-bk1/net/sched/sch_generic.c	2005/01/05 01:21:04	1.1
+++ 2610-bk1/net/sched/sch_generic.c	2005/01/05 01:36:26
@@ -152,7 +152,7 @@
 					spin_lock(&dev->queue_lock);
 					goto collision; 
 				}
-			}
+			} 
 
 			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
@@ -162,6 +162,11 @@
 			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
+			if (!netif_carrier_ok(dev)) {
+				kfree_skb(skb);
+				q->qstats.drops++;
+				return -1;
+			}
 		}
 
 		/* Device kicked us out :(

--=-0846Th3rEGC6QKddUtsg--
