From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: moxa: constify net_device_ops structures
Date: Sat, 21 Jan 2017 11:44:38 +0530
Message-ID: <1484979278-29261-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, dan.carpenter@oracle.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33836 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbdAUGOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 01:14:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare net_device_ops structures as const as they are only stored in
the netdev_ops field of a net_device structure. This field is of type
const, so net_device_ops structures having same properties can be made
const too.
Done using Coccinelle:

@r1 disable optional_qualifier@
identifier i;
position p;
@@
static struct net_device_ops i@p={...};

@ok1@
identifier r1.i;
position p;
struct net_device ndev;
@@
ndev.netdev_ops=&i@p

@bad@
position p!={r1.p,ok1.p};
identifier r1.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r1.i;
@@
+const
struct net_device_ops i;

File size before:
   text	   data	    bss	    dec	    hex	filename
   4821	    744	      0	   5565	   15bd ethernet/moxa/moxart_ether.o

File size after:
   text	   data	    bss	    dec	    hex	filename
   5373	    192	      0	   5565	   15bd ethernet/moxa/moxart_ether.o

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 9774b50..6a6525f 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -436,7 +436,7 @@ static void moxart_mac_set_rx_mode(struct net_device *ndev)
 	spin_unlock_irq(&priv->txlock);
 }
 
-static struct net_device_ops moxart_netdev_ops = {
+static const struct net_device_ops moxart_netdev_ops = {
 	.ndo_open		= moxart_mac_open,
 	.ndo_stop		= moxart_mac_stop,
 	.ndo_start_xmit		= moxart_mac_start_xmit,
-- 
1.9.1
