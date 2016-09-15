From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/3] l2tp: constify net_device_ops structures
Date: Thu, 15 Sep 2016 22:23:26 +0200
Message-ID: <1473971006-2074-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1473971006-2074-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:28380
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756280AbcIOUlo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:41:44 -0400
In-Reply-To: <1473971006-2074-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for net_device_ops structures that are only stored in the netdev_ops
field of a net_device structure.  This field is declared const, so
net_device_ops structures that have this property can be declared as const
also.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct net_device_ops i@p = { ... };

@ok@
identifier r.i;
struct net_device e;
position p;
@@
e.netdev_ops = &i@p;

@bad@
position p != {r.p,ok.p};
identifier r.i;
struct net_device_ops e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct net_device_ops i = { ... };
// </smpl>

The result of size on this file before the change is:
   text	      data     bss     dec         hex	  filename
   3401        931      44    4376        1118	net/l2tp/l2tp_eth.o

and after the change it is:
   text	     data        bss	    dec	    hex	filename
   3993       347         44       4384    1120	net/l2tp/l2tp_eth.o

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/l2tp/l2tp_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 57fc5a4..ddb744c 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -121,7 +121,7 @@ static struct rtnl_link_stats64 *l2tp_eth_get_stats64(struct net_device *dev,
 }
 
 
-static struct net_device_ops l2tp_eth_netdev_ops = {
+static const struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_init		= l2tp_eth_dev_init,
 	.ndo_uninit		= l2tp_eth_dev_uninit,
 	.ndo_start_xmit		= l2tp_eth_dev_xmit,
