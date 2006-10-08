From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [patch 2/3] atmel: use ARRAY_SIZE()
Date: Sun, 08 Oct 2006 00:14:29 -0400
Message-ID: <20061008041552.103205043.dtor@insightbb.com>
References: <20061008041427.216886195.dtor@insightbb.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:29491 "EHLO
	asav08.insightbb.com") by vger.kernel.org with ESMTP
	id S1750778AbWJHERi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 00:17:38 -0400
To: linville@tuxdriver.com
Content-Disposition: inline; filename=atmel-use-array-size.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET: atmel - switch to using ARRAY_SIZE()

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 drivers/net/wireless/atmel.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

Index: work/drivers/net/wireless/atmel.c
===================================================================
--- work.orig/drivers/net/wireless/atmel.c
+++ work/drivers/net/wireless/atmel.c
@@ -1193,7 +1193,7 @@ static irqreturn_t service_interrupt(int
 
 		atmel_set_gcr(dev, GCR_ACKINT); /* acknowledge interrupt */
 
-		for (i = 0; i < sizeof(irq_order)/sizeof(u8); i++)
+		for (i = 0; i < ARRAY_SIZE(irq_order); i++)
 			if (isr & irq_order[i])
 				break;
 
@@ -1345,10 +1345,10 @@ int atmel_open(struct net_device *dev)
 		atmel_set_mib8(priv, Phy_Mib_Type, PHY_MIB_REG_DOMAIN_POS, priv->reg_domain);
 	} else {
 		priv->reg_domain = atmel_get_mib8(priv, Phy_Mib_Type, PHY_MIB_REG_DOMAIN_POS);
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 			if (priv->reg_domain == channel_table[i].reg_domain)
 				break;
-		if (i == sizeof(channel_table)/sizeof(channel_table[0])) {
+		if (i == ARRAY_SIZE(channel_table)) {
 			priv->reg_domain = REG_DOMAIN_MKK1;
 			printk(KERN_ALERT "%s: failed to get regulatory domain: assuming MKK1.\n", dev->name);
 		}
@@ -1393,7 +1393,7 @@ static int atmel_validate_channel(struct
 	   else return suitable default channel */
 	int i;
 
-	for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+	for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 		if (priv->reg_domain == channel_table[i].reg_domain) {
 			if (channel >= channel_table[i].min &&
 			    channel <= channel_table[i].max)
@@ -1437,7 +1437,7 @@ static int atmel_proc_output (char *buf,
 		}
 
 		r = "<unknown>";
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 			if (priv->reg_domain == channel_table[i].reg_domain)
 				r = channel_table[i].name;
 
@@ -2375,7 +2375,7 @@ static int atmel_get_range(struct net_de
 	range->min_nwid = 0x0000;
 	range->max_nwid = 0x0000;
 	range->num_channels = 0;
-	for (j = 0; j < sizeof(channel_table)/sizeof(channel_table[0]); j++)
+	for (j = 0; j < ARRAY_SIZE(channel_table); j++)
 		if (priv->reg_domain == channel_table[j].reg_domain) {
 			range->num_channels = channel_table[j].max - channel_table[j].min + 1;
 			break;
@@ -2581,9 +2581,9 @@ static const struct iw_priv_args atmel_p
 
 static const struct iw_handler_def atmel_handler_def =
 {
-	.num_standard	= sizeof(atmel_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(atmel_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(atmel_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(atmel_handler),
+	.num_private	= ARRAY_SIZE(atmel_private_handler),
+	.num_private_args = ARRAY_SIZE(atmel_private_args),
 	.standard	= (iw_handler *) atmel_handler,
 	.private	= (iw_handler *) atmel_private_handler,
 	.private_args	= (struct iw_priv_args *) atmel_private_args,
@@ -2647,7 +2647,7 @@ static int atmel_ioctl(struct net_device
 
 		domain[REGDOMAINSZ] = 0;
 		rc = -EINVAL;
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++) {
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++) {
 			/* strcasecmp doesn't exist in the library */
 			char *a = channel_table[i].name;
 			char *b = domain;
