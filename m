From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Mon, 15 Feb 2010 00:13:19 -0800 (PST)
Message-ID: <20100215.001319.150697350.davem@davemloft.net>
References: <20100212.123129.163263355.davem@davemloft.net>
	<1266194829.16721.940.camel@Joe-Laptop.home>
	<20100214.224108.51485961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755394Ab0BOING (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 03:13:06 -0500
In-Reply-To: <20100214.224108.51485961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 14 Feb 2010 22:41:08 -0800 (PST)

> It looks good here and I'll give it a quick test before
> doing a final push of this into net-next-2.6

Joe, I just added the following refinements on top of your
changes to net-next-2.6

Thanks!

niu: Refinements to kernel logging.

Fix unconditional empty kerne log message every interrupt.

Kill some informational log messages that are superfluous
and anyways occur before the netdev is registered.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   26 +-------------------------
 1 files changed, 1 insertions(+), 25 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 347788f..5e604e3 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3204,9 +3204,6 @@ static int fflp_early_init(struct niu *np)
 	parent = np->parent;
 	err = 0;
 	if (!(parent->flags & PARENT_FLGS_CLS_HWINIT)) {
-		netif_printk(np, probe, KERN_DEBUG, np->dev,
-			     "%s() Initting hw on port %u\n",
-			     __func__, np->port);
 		if (np->parent->plat_type != PLAT_TYPE_NIU) {
 			fflp_reset(np);
 			fflp_set_timings(np);
@@ -3248,8 +3245,6 @@ static int fflp_early_init(struct niu *np)
 
 		vlan_tbl_clear(np);
 
-		netif_printk(np, probe, KERN_DEBUG, np->dev,
-			     "%s() Success\n", __func__);
 		parent->flags |= PARENT_FLGS_CLS_HWINIT;
 	}
 out:
@@ -4246,13 +4241,11 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	v2 = nr64(LDSV2(ldg));
 
 	if (netif_msg_intr(np))
-		pr_cont(" v0[%llx] v1[%llx] v2[%llx]",
+		pr_cont(" v0[%llx] v1[%llx] v2[%llx]\n",
 		       (unsigned long long) v0,
 		       (unsigned long long) v1,
 		       (unsigned long long) v2);
 
-	pr_cont("\n");
-
 	if (unlikely(!v0 && !v1 && !v2)) {
 		spin_unlock_irqrestore(&np->lock, flags);
 		return IRQ_NONE;
@@ -8577,9 +8570,6 @@ static int __devinit niu_get_and_validate_port(struct niu *np)
 		}
 	}
 
-	netif_printk(np, probe, KERN_DEBUG, np->dev,
-		     "%s() port[%d] num_ports[%d]\n",
-		     __func__, np->port, parent->num_ports);
 	if (np->port >= parent->num_ports)
 		return -ENODEV;
 
@@ -8965,9 +8955,6 @@ static int __devinit niu_probe_ports(struct niu *np)
 	struct niu_parent *parent = np->parent;
 	int err, i;
 
-	netif_printk(np, probe, KERN_DEBUG, np->dev,
-		     "%s() port_phy[%08x]\n", __func__, parent->port_phy);
-
 	if (parent->port_phy == PORT_PHY_UNKNOWN) {
 		err = walk_phys(np, parent);
 		if (err)
@@ -8988,10 +8975,6 @@ static int __devinit niu_classifier_swstate_init(struct niu *np)
 {
 	struct niu_classifier *cp = &np->clas;
 
-	netif_printk(np, probe, KERN_DEBUG, np->dev,
-		     "%s() num_tcam(%d)\n",
-		     __func__, np->parent->tcam_num_entries);
-
 	cp->tcam_top = (u16) np->port;
 	cp->tcam_sz = np->parent->tcam_num_entries / np->parent->num_ports;
 	cp->h1_init = 0xffffffff;
@@ -9506,9 +9489,6 @@ static struct niu_parent * __devinit niu_new_parent(struct niu *np,
 	struct niu_parent *p;
 	int i;
 
-	netif_printk(np, probe, KERN_DEBUG, np->dev,
-		     "%s() Creating new parent\n", __func__);
-
 	plat_dev = platform_device_register_simple("niu", niu_parent_index,
 						   NULL, 0);
 	if (IS_ERR(plat_dev))
@@ -9573,10 +9553,6 @@ static struct niu_parent * __devinit niu_get_parent(struct niu *np,
 	struct niu_parent *p, *tmp;
 	int port = np->port;
 
-	netif_printk(np, probe, KERN_DEBUG, np->dev,
-		     "%s() platform_type[%u] port[%u]\n",
-		     __func__, ptype, port);
-
 	mutex_lock(&niu_parent_lock);
 	p = NULL;
 	list_for_each_entry(tmp, &niu_parent_list, list) {
-- 
1.6.6.1

