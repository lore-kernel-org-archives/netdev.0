From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: fix potential null pointer dereference
Date: Tue, 23 May 2017 18:18:37 -0500
Message-ID: <20170523231837.GA9364@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add null check to avoid a potential null pointer dereference.

Addresses-Coverity-ID: 1408831
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/gtp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 4fea1b3..7b652bb 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -873,7 +873,7 @@ static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = dev_get_by_index_rcu(net, nla_get_u32(nla[GTPA_LINK]));
-	if (dev->netdev_ops == &gtp_netdev_ops)
+	if (dev && dev->netdev_ops == &gtp_netdev_ops)
 		gtp = netdev_priv(dev);
 
 	put_net(net);
-- 
2.5.0
