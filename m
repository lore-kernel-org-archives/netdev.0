From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) syncpp - sealevel fix regression
Date: Mon, 13 Oct 2003 11:09:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013110957.277c675c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My earlier change broke the if_ptr assumption used by SPPP drivers.
This makes sealevel driver do if_ptr like it used to.

This is a resend of an earlier patch which seems not to have been included.

diff -Nru a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
--- a/drivers/net/wan/sealevel.c	Fri Oct  3 11:28:36 2003
+++ b/drivers/net/wan/sealevel.c	Fri Oct  3 11:28:36 2003
@@ -31,6 +31,7 @@
 
 struct slvl_device
 {
+	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_channel *chan;
 	struct ppp_device pppdev;
 	int channel;
@@ -238,6 +239,7 @@
 		return NULL;
 
 	sv = d->priv;
+	sv->if_ptr = &sv->pppdev;
 	sv->pppdev.dev = d;
 	d->base_addr = iobase;
 	d->irq = irq;
