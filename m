From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH 1/6] ariadne: convert to net_device_ops
Date: Fri, 10 Apr 2009 21:59:24 +0400
Message-ID: <20090410175924.GA20243@orion>
References: <20090410032407.GA9004@orion> <49DF7042.7090502@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: David Miller <davem@davemloft.net>,
	Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49DF7042.7090502@computer.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2009 at 06:13:54PM +0200, Jan Ceuleers wrote:
> Alexander Beregalov wrote:
> > 
> > Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ...
> > @@ -197,13 +209,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
> >      dev->mem_start = ZTWO_VADDR(mem_start);
> >      dev->mem_end = dev->mem_start+ARIADNE_RAM_SIZE;
> >  
> > -    dev->open = &ariadne_open;
> > -    dev->stop = &ariadne_close;
> > -    dev->hard_start_xmit = &ariadne_start_xmit;
> > -    dev->tx_timeout = &ariadne_tx_timeout;
> > +    dev->netdev_ops = &ariadne_netdev_ops;;
> 
> We don't really need two semicolons there but I suppose that they won't 
> hurt.
Thanks!

David, please apply this patch

---
From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/6] ariadne: convert to net_device_ops


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
---

 drivers/net/ariadne.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index e1d72e0..58e8d52 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -155,6 +155,18 @@ static struct zorro_driver ariadne_driver = {
     .remove	= __devexit_p(ariadne_remove_one),
 };
 
+static const struct net_device_ops ariadne_netdev_ops = {
+	.ndo_open		= ariadne_open,
+	.ndo_stop		= ariadne_close,
+	.ndo_start_xmit		= ariadne_start_xmit,
+	.ndo_tx_timeout		= ariadne_tx_timeout,
+	.ndo_get_stats		= ariadne_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __devinit ariadne_init_one(struct zorro_dev *z,
 				      const struct zorro_device_id *ent)
 {
@@ -197,13 +209,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
     dev->mem_start = ZTWO_VADDR(mem_start);
     dev->mem_end = dev->mem_start+ARIADNE_RAM_SIZE;
 
-    dev->open = &ariadne_open;
-    dev->stop = &ariadne_close;
-    dev->hard_start_xmit = &ariadne_start_xmit;
-    dev->tx_timeout = &ariadne_tx_timeout;
+    dev->netdev_ops = &ariadne_netdev_ops;
     dev->watchdog_timeo = 5*HZ;
-    dev->get_stats = &ariadne_get_stats;
-    dev->set_multicast_list = &set_multicast_list;
 
     err = register_netdev(dev);
     if (err) {
