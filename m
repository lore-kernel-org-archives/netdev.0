From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] net drivers assignment in conditional context
Date: Tue, 22 Jun 2004 14:23:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622142351.1857bb9b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix several warnings from sparse about assignment used in conditional
context in net drivers

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c505.c b/drivers/net/3c505.c
--- a/drivers/net/3c505.c	2004-06-22 13:43:47 -07:00
+++ b/drivers/net/3c505.c	2004-06-22 13:43:47 -07:00
@@ -1373,7 +1373,7 @@
 		if (elp_sense(dev) == 0)
 			return dev->base_addr;
 	} else
-		while ((dev->base_addr = addr_list[idx++])) {
+		while ((dev->base_addr = addr_list[idx++]) != 0) {
 			if (elp_sense(dev) == 0)
 				return dev->base_addr;
 		}
diff -Nru a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/cs89x0.c	2004-06-22 13:43:46 -07:00
@@ -1430,7 +1430,7 @@
            course, if you're on a slow machine, and packets are arriving
            faster than you can read them off, you're screwed.  Hasta la
            vista, baby!  */
-	while ((status = readword(dev, ISQ_PORT))) {
+	while ((status = readword(dev, ISQ_PORT)) != 0) {
 		if (net_debug > 4)printk("%s: event=%04x\n", dev->name, status);
 		handled = 1;
 		switch(status & ISQ_EVENT_MASK) {
diff -Nru a/drivers/net/eth16i.c b/drivers/net/eth16i.c
--- a/drivers/net/eth16i.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/eth16i.c	2004-06-22 13:43:46 -07:00
@@ -446,12 +446,12 @@
 		return -ENXIO;
 
 	/* Seek card from the ISA io address space */
-	for(i = 0; (ioaddr = eth16i_portlist[i]) ; i++)
+	for(i = 0; (ioaddr = eth16i_portlist[i]) != 0; i++)
 		if(eth16i_probe1(dev, ioaddr) == 0)
 			return 0;
 
 	/* Seek card from the EISA io address space */
-	for(i = 0; (ioaddr = eth32i_portlist[i]) ; i++)
+	for(i = 0; (ioaddr = eth32i_portlist[i]) != 0; i++)
 		if(eth16i_probe1(dev, ioaddr) == 0)
 			return 0;
 
diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c
--- a/drivers/net/ne.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/ne.c	2004-06-22 13:43:46 -07:00
@@ -242,7 +242,7 @@
 		while ((idev = pnp_find_dev(NULL,
 					    isapnp_clone_list[i].vendor,
 					    isapnp_clone_list[i].function,
-					    idev))) {
+					    idev)) != NULL) {
 			/* Avoid already found cards from previous calls */
 			if (pnp_device_attach(idev) < 0)
 				continue;
diff -Nru a/drivers/net/ni52.c b/drivers/net/ni52.c
--- a/drivers/net/ni52.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/ni52.c	2004-06-22 13:43:46 -07:00
@@ -855,7 +855,7 @@
 
 	WAIT_4_SCB_CMD(); /* wait for last command	*/
 
-	while((stat=p->scb->cus & STAT_MASK))
+	while((stat=p->scb->cus & STAT_MASK) != 0)
 	{
 		p->scb->cmd_cuc = stat;
 		ni_attn586();
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/pcnet32.c	2004-06-22 13:43:46 -07:00
@@ -959,7 +959,7 @@
     unsigned int *port, ioaddr;
 
     /* search for PCnet32 VLB cards at known addresses */
-    for (port = pcnet32_portlist; (ioaddr = *port); port++) {
+    for (port = pcnet32_portlist; (ioaddr = *port) != 0; port++) {
 	if (request_region(ioaddr, PCNET32_TOTAL_SIZE, "pcnet32_probe_vlbus")) {
 	    /* check if there is really a pcnet chip on that ioaddr */
 	    if ((inb(ioaddr + 14) == 0x57) && (inb(ioaddr + 15) == 0x57)) {
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2004-06-22 13:43:47 -07:00
+++ b/drivers/net/via-rhine.c	2004-06-22 13:43:47 -07:00
@@ -1389,7 +1389,7 @@
 
 	ioaddr = dev->base_addr;
 
-	while ((intr_status = get_intr_status(dev))) {
+	while ((intr_status = get_intr_status(dev)) != 0) {
 		handled = 1;
 
 		/* Acknowledge all of the current interrupt sources ASAP. */
diff -Nru a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
--- a/drivers/net/wan/syncppp.c	2004-06-22 13:43:46 -07:00
+++ b/drivers/net/wan/syncppp.c	2004-06-22 13:43:46 -07:00
@@ -1142,7 +1142,7 @@
 
 	spin_lock_irqsave(&spppq_lock, flags);
 	/* Remove the entry from the keepalive list. */
-	for (q = &spppq; (p = *q); q = &p->pp_next)
+	for (q = &spppq; (p = *q) != NULL; q = &p->pp_next)
 		if (p == sp) {
 			*q = p->pp_next;
 			break;
