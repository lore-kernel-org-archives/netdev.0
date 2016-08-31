From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 5/6] dwc_eth_qos: constify ethtool_ops structures
Date: Wed, 31 Aug 2016 09:30:47 +0200
Message-ID: <1472628648-3603-6-git-send-email-Julia.Lawall@lip6.fr>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lars Persson <lars.persson@axis.com>
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
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 5a3941b..c25d971 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2743,7 +2743,7 @@ static void dwceqos_set_msglevel(struct net_device *ndev, u32 msglevel)
 	lp->msg_enable = msglevel;
 }
 
-static struct ethtool_ops dwceqos_ethtool_ops = {
+static const struct ethtool_ops dwceqos_ethtool_ops = {
 	.get_drvinfo    = dwceqos_get_drvinfo,
 	.get_link       = ethtool_op_get_link,
 	.get_pauseparam = dwceqos_get_pauseparam,
