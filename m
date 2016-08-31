From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/6] net: ethernet: et131x: constify ethtool_ops structures
Date: Wed, 31 Aug 2016 09:30:44 +0200
Message-ID: <1472628648-3603-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/ethernet/agere/et131x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index c83ebae..9066838 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -2961,7 +2961,7 @@ static void et131x_get_drvinfo(struct net_device *netdev,
 		sizeof(info->bus_info));
 }
 
-static struct ethtool_ops et131x_ethtool_ops = {
+static const struct ethtool_ops et131x_ethtool_ops = {
 	.get_drvinfo	= et131x_get_drvinfo,
 	.get_regs_len	= et131x_get_regs_len,
 	.get_regs	= et131x_get_regs,
