From: Matt Mackall <mpm@selenic.com>
Subject: [RFC] [PATCH 2/3] tg3 netpoll hook
Date: Thu, 2 Oct 2003 20:45:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003014505.GS1897@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 l-mpm/drivers/net/tg3.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)

diff -puN drivers/net/tg3.c~tg3-poll drivers/net/tg3.c
--- l/drivers/net/tg3.c~tg3-poll	2003-09-25 11:47:30.000000000 -0500
+++ l-mpm/drivers/net/tg3.c	2003-09-25 11:56:37.000000000 -0500
@@ -2475,6 +2475,15 @@ static irqreturn_t tg3_interrupt(int irq
 static int tg3_init_hw(struct tg3 *);
 static int tg3_halt(struct tg3 *);
 
+#ifdef HAVE_POLL_CONTROLLER
+static void tg3_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	tg3_interrupt (dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static void tg3_reset_task(void *_data)
 {
 	struct tg3 *tp = _data;
@@ -7482,6 +7491,10 @@ static struct pci_dev * __devinit tg3_fi
 	return peer;
 }
 
+#ifdef HAVE_POLL_CONTROLLER
+static void tg3_poll_controller(struct net_device *dev);
+#endif
+
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -7632,6 +7645,9 @@ static int __devinit tg3_init_one(struct
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
+#ifdef HAVE_POLL_CONTROLLER
+	dev->poll_controller = tg3_poll_controller;
+#endif
 
 	err = tg3_get_invariants(tp);
 	if (err) {

_


-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
