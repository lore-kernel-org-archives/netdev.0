From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in /hamradio/
Date: Sun, 29 Feb 2004 14:35:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229143510.0eb97123.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/hamradio/baycom_epp.c     |    4 ++--
 drivers/net/hamradio/baycom_par.c     |    8 ++++----
 drivers/net/hamradio/baycom_ser_fdx.c |    6 +++---
 drivers/net/hamradio/baycom_ser_hdx.c |    6 +++---
 4 files changed, 12 insertions(+), 12 deletions(-)

diff -puN drivers/net/hamradio/baycom_epp.c~net_hamradio_casts drivers/net/hamradio/baycom_epp.c
--- linux-263-229/drivers/net/hamradio/baycom_epp.c~net_hamradio_casts	2004-02-29 13:55:12.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/hamradio/baycom_epp.c	2004-02-29 13:55:12.000000000 -0800
@@ -646,7 +646,7 @@ static int transmit(struct baycom_state 
 
 static void do_rxpacket(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	struct sk_buff *skb;
 	unsigned char *cp;
 	unsigned pktlen;
@@ -705,7 +705,7 @@ static void do_rxpacket(struct net_devic
         
 static int receive(struct net_device *dev, int cnt)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	struct parport *pp = bc->pdev->port;
         unsigned int bitbuf, notbitstream, bitstream, numbits, state;
 	unsigned char tmp[128];
diff -puN drivers/net/hamradio/baycom_par.c~net_hamradio_casts drivers/net/hamradio/baycom_par.c
--- linux-263-229/drivers/net/hamradio/baycom_par.c~net_hamradio_casts	2004-02-29 13:55:12.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/hamradio/baycom_par.c	2004-02-29 13:55:12.000000000 -0800
@@ -272,7 +272,7 @@ static __inline__ void par96_rx(struct n
 static void par96_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 
 	if (!dev || !bc || bc->hdrv.magic != HDLCDRV_MAGIC)
 		return;
@@ -302,7 +302,7 @@ static void par96_interrupt(int irq, voi
 static void par96_wakeup(void *handle)
 {
         struct net_device *dev = (struct net_device *)handle;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 
 	printk(KERN_DEBUG "baycom_par: %s: why am I being woken up?\n", dev->name);
 	if (!parport_claim(bc->pdev))
@@ -313,7 +313,7 @@ static void par96_wakeup(void *handle)
 
 static int par96_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	struct parport *pp;
 
 	if (!dev || !bc)
@@ -362,7 +362,7 @@ static int par96_open(struct net_device 
 
 static int par96_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	struct parport *pp;
 
 	if (!dev || !bc)
diff -puN drivers/net/hamradio/baycom_ser_fdx.c~net_hamradio_casts drivers/net/hamradio/baycom_ser_fdx.c
--- linux-263-229/drivers/net/hamradio/baycom_ser_fdx.c~net_hamradio_casts	2004-02-29 13:55:12.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/hamradio/baycom_ser_fdx.c	2004-02-29 13:55:12.000000000 -0800
@@ -281,7 +281,7 @@ static __inline__ void ser12_rx(struct n
 static irqreturn_t ser12_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	struct timeval tv;
 	unsigned char iir, msr;
 	unsigned int txcount = 0;
@@ -407,7 +407,7 @@ static enum uart ser12_check_uart(unsign
 
 static int ser12_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	enum uart u;
 
 	if (!dev || !bc)
@@ -466,7 +466,7 @@ static int ser12_open(struct net_device 
 
 static int ser12_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 
 	if (!dev || !bc)
 		return -EINVAL;
diff -puN drivers/net/hamradio/baycom_ser_hdx.c~net_hamradio_casts drivers/net/hamradio/baycom_ser_hdx.c
--- linux-263-229/drivers/net/hamradio/baycom_ser_hdx.c~net_hamradio_casts	2004-02-29 13:55:12.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/hamradio/baycom_ser_hdx.c	2004-02-29 13:55:12.000000000 -0800
@@ -375,7 +375,7 @@ static inline void ser12_rx(struct net_d
 static irqreturn_t ser12_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	unsigned char iir;
 
 	if (!dev || !bc || bc->hdrv.magic != HDLCDRV_MAGIC)
@@ -468,7 +468,7 @@ static enum uart ser12_check_uart(unsign
 
 static int ser12_open(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 	enum uart u;
 
 	if (!dev || !bc)
@@ -511,7 +511,7 @@ static int ser12_open(struct net_device 
 
 static int ser12_close(struct net_device *dev)
 {
-	struct baycom_state *bc = (struct baycom_state *)dev->priv;
+	struct baycom_state *bc = dev->priv;
 
 	if (!dev || !bc)
 		return -EINVAL;

_

--
~Randy
