From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/3] hisilicon: constify net_device_ops structures
Date: Thu, 15 Sep 2016 22:23:24 +0200
Message-ID: <1473971006-2074-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1473971006-2074-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
        Salil Mehta <salil.mehta@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yisen Zhuang <yisen.zhuang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:28380
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754876AbcIOUlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:41:42 -0400
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
   7995	       848       8    8851        2293
   drivers/net/ethernet/hisilicon/hip04_eth.o

and after the change it is:

   text	     data        bss	    dec	    hex	filename
   8571	      256          8       8835    2283
   drivers/net/ethernet/hisilicon/hip04_eth.o

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/hisilicon/hip04_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index a90ab40..415ffa1 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -761,7 +761,7 @@ static const struct ethtool_ops hip04_ethtool_ops = {
 	.get_drvinfo		= hip04_get_drvinfo,
 };
 
-static struct net_device_ops hip04_netdev_ops = {
+static const struct net_device_ops hip04_netdev_ops = {
 	.ndo_open		= hip04_mac_open,
 	.ndo_stop		= hip04_mac_stop,
 	.ndo_get_stats		= hip04_get_stats,
