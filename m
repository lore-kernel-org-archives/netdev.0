From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/6] drivers/net: remove null pointer dereference
Date: Mon, 12 May 2008 15:37:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805121537320.3694@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58516 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbYELNiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 09:38:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

If dev is NULL, it is not possible to access its name field.  So I have
simply modified the error message to drop the printing of the name field.


This problem was found using the following semantic match
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E, E1;
identifier f;
statement S1,S2,S3;
@@

* if (E == NULL)
{
  ... when != if (E == NULL) S1 else S2
      when != E = E1
* E->f
  ... when any
  return ...;
}
else S3
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---

diff -u -p a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
--- a/drivers/net/au1000_eth.c	2008-04-27 11:41:11.000000000 +0200
+++ b/drivers/net/au1000_eth.c	2008-05-12 09:32:54.000000000 +0200
@@ -1242,7 +1242,7 @@ static irqreturn_t au1000_interrupt(int 
 	struct net_device *dev = (struct net_device *) dev_id;
 
 	if (dev == NULL) {
-		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
+		printk(KERN_ERR "isr: null dev ptr\n");
 		return IRQ_RETVAL(1);
 	}
 
