From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) wan/cosa - channel name pointer
Date: Tue, 25 Nov 2003 11:52:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125115222.593d074c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This driver keeps a copy of the device name in the local data structure;
the problem is that the network device name can be changed with nameif
but the local copy won't change.  Changing this to a pointer rather than
a copy and it is not a problem.

diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Mon Nov 24 15:38:28 2003
+++ b/drivers/net/wan/cosa.c	Mon Nov 24 15:38:28 2003
@@ -120,7 +120,7 @@
 	struct cosa_data *cosa;	/* Pointer to the per-card structure */
 	int txsize;	/* Size of transmitted data */
 	char *txbuf;	/* Transmit buffer */
-	char name[COSA_MAX_NAME];	/* channel name */
+	char *name;	/* network device name */
 
 	/* The HW layer interface */
 	/* routine called from the RX interrupt */
@@ -429,8 +429,6 @@
  */
 static __inline__ void channel_init(struct channel_data *chan)
 {
-	sprintf(chan->name, "cosa%dc%d", chan->cosa->num, chan->num);
-
 	/* Initialize the chardev data structures */
 	chardev_channel_init(chan);
 
@@ -603,7 +601,8 @@
 	memset(chan->pppdev.dev, 0, sizeof(struct net_device));
 	sppp_attach(&chan->pppdev);
 	d=chan->pppdev.dev;
-	strcpy(d->name, chan->name);
+	sprintf(d->name, "cosa%dc%d", chan->cosa->num, chan->num);
+	chan->name = d->name;
 	d->base_addr = chan->cosa->datareg;
 	d->irq = chan->cosa->irq;
 	d->dma = chan->cosa->dma;


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
