From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sppp - fix sealevel
Date: Fri, 3 Oct 2003 14:47:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003144758.78c52154.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My earlier change broke the if_ptr assumption used by SPPP drivers.
This makes sealevel driver do if_ptr like it used to.

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
