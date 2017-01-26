From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] gtp: Adjust 12 checks for null pointers
Date: Thu, 26 Jan 2017 11:19:32 +0100
Message-ID: <10c20387-4a38-726e-ea58-2a06d50239a5@users.sourceforge.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 25 Jan 2017 22:50:23 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script "checkpatch.pl" pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/gtp.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f0c123101aa9..7e38786361d8 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -785,12 +785,12 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 
 	gtp->addr_hash = kmalloc_array(hsize, sizeof(*gtp->addr_hash),
 				       GFP_KERNEL);
-	if (gtp->addr_hash == NULL)
+	if (!gtp->addr_hash)
 		return -ENOMEM;
 
 	gtp->tid_hash = kmalloc_array(hsize, sizeof(*gtp->tid_hash),
 				      GFP_KERNEL);
-	if (gtp->tid_hash == NULL)
+	if (!gtp->tid_hash)
 		goto err1;
 
 	gtp->hash_size = hsize;
@@ -832,7 +832,7 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	netdev_dbg(dev, "enable gtp on %d, %d\n", fd_gtp0, fd_gtp1);
 
 	sock0 = sockfd_lookup(fd_gtp0, &err);
-	if (sock0 == NULL) {
+	if (!sock0) {
 		netdev_dbg(dev, "socket fd=%d not found (gtp0)\n", fd_gtp0);
 		return -ENOENT;
 	}
@@ -844,7 +844,7 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	}
 
 	sock1u = sockfd_lookup(fd_gtp1, &err);
-	if (sock1u == NULL) {
+	if (!sock1u) {
 		netdev_dbg(dev, "socket fd=%d not found (gtp1u)\n", fd_gtp1);
 		err = -ENOENT;
 		goto err1;
@@ -957,7 +957,7 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 	}
 
 	pctx = kmalloc(sizeof(*pctx), GFP_KERNEL);
-	if (pctx == NULL)
+	if (!pctx)
 		return -ENOMEM;
 
 	ipv4_pdp_fill(pctx, info);
@@ -1029,7 +1029,7 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
+	if (!dev) {
 		put_net(net);
 		return -ENODEV;
 	}
@@ -1055,7 +1055,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
+	if (!dev) {
 		put_net(net);
 		return -ENODEV;
 	}
@@ -1079,7 +1079,7 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	if (pctx == NULL)
+	if (!pctx)
 		return -ENOENT;
 
 	if (pctx->gtp_version == GTP_V0)
@@ -1105,7 +1105,7 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 
 	genlh = genlmsg_put(skb, snd_portid, snd_seq, &gtp_genl_family, 0,
 			    type);
-	if (genlh == NULL)
+	if (!genlh)
 		goto nlmsg_failure;
 
 	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version) ||
@@ -1163,7 +1163,7 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
+	if (!dev) {
 		put_net(net);
 		return -ENODEV;
 	}
@@ -1188,13 +1188,13 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 		pctx = ipv4_pdp_find(gtp, ip);
 	}
 
-	if (pctx == NULL) {
+	if (!pctx) {
 		err = -ENOENT;
 		goto err_unlock;
 	}
 
 	skb2 = genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
-	if (skb2 == NULL) {
+	if (!skb2) {
 		err = -ENOMEM;
 		goto err_unlock;
 	}
-- 
2.11.0
