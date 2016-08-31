From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/6] net: systemport: constify ethtool_ops structures
Date: Wed, 31 Aug 2016 09:30:48 +0200
Message-ID: <1472628648-3603-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:25927 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758930AbcHaHtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 03:49:21 -0400
In-Reply-To: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for ethtool_ops structures that are only stored in the ethtool_ops
field of a net_device structure or passed as the second argument to
netdev_set_default_ethtool_ops.  These contexts are declared const, so
ethtool_ops structures that have these properties can be declared as const
also.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct ethtool_ops i@p = { ... };

@ok1@
identifier r.i;
struct net_device e;
position p;
@@
e.ethtool_ops = &i@p;

@ok2@
identifier r.i;
expression e;
position p;
@@
netdev_set_default_ethtool_ops(e, &i@p)

@bad@
position p != {r.p,ok1.p,ok2.p};
identifier r.i;
@@
i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct ethtool_ops i = { ... };
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/broadcom/bcmsysport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index b2d3086..dbbe8a5 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1692,7 +1692,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	return 0;
 }
 
-static struct ethtool_ops bcm_sysport_ethtool_ops = {
+static const struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.get_drvinfo		= bcm_sysport_get_drvinfo,
 	.get_msglevel		= bcm_sysport_get_msglvl,
 	.set_msglevel		= bcm_sysport_set_msglvl,
