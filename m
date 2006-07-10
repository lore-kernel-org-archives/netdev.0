From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.18-rc1-mm1 inconsistent lock state in netpoll_send_skb
Date: Mon, 10 Jul 2006 10:40:23 +0200
Message-ID: <1152520823.4874.0.camel@laptopd505.fenrus.org>
References: <20060709021106.9310d4d1.akpm@osdl.org>
	 <44B17735.4060006@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:31170 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751366AbWGJIk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 04:40:28 -0400
To: Laurent Riffard <laurent.riffard@free.fr>
In-Reply-To: <44B17735.4060006@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-07-09 at 23:37 +0200, Laurent Riffard wrote:
> ei_start_xmit

please try this patch

---
 drivers/net/8390.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6.17-mm4/drivers/net/8390.c
===================================================================
--- linux-2.6.17-mm4.orig/drivers/net/8390.c
+++ linux-2.6.17-mm4/drivers/net/8390.c
@@ -299,7 +299,7 @@ static int ei_start_xmit(struct sk_buff 
 	 *	Slow phase with lock held.
 	 */
 	 
-	disable_irq_nosync(dev->irq);
+	disable_irq_nosync_lockdep(dev->irq);
 	
 	spin_lock(&ei_local->page_lock);
 	
@@ -338,7 +338,7 @@ static int ei_start_xmit(struct sk_buff 
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
-		enable_irq(dev->irq);
+		enable_irq_lockdep(dev->irq);
 		ei_local->stat.tx_errors++;
 		return 1;
 	}
@@ -379,7 +379,7 @@ static int ei_start_xmit(struct sk_buff 
 	outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 	
 	spin_unlock(&ei_local->page_lock);
-	enable_irq(dev->irq);
+	enable_irq_lockdep(dev->irq);
 
 	dev_kfree_skb (skb);
 	ei_local->stat.tx_bytes += send_length;
@@ -505,9 +505,9 @@ irqreturn_t ei_interrupt(int irq, void *
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void ei_poll(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	disable_irq_lockdep(dev->irq);
 	ei_interrupt(dev->irq, dev, NULL);
-	enable_irq(dev->irq);
+	enable_irq_lockdep(dev->irq);
 }
 #endif
 


