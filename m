From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] 6lowpan: release device on error path
Date: Thu, 7 Nov 2013 10:44:45 +0300
Message-ID: <20131107074445.GD21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Alan Ott <alan@signal11.us>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently added a new error path and it needs a dev_put().

Fixes: 7adac1ec8198 ('6lowpan: Only make 6lowpan links to IEEE802154 devices')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Compile tested only.  Please review carefully.

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 9497c6f..426b5df 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1358,8 +1358,10 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	real_dev = dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
 	if (!real_dev)
 		return -ENODEV;
-	if (real_dev->type != ARPHRD_IEEE802154)
+	if (real_dev->type != ARPHRD_IEEE802154) {
+		dev_put(real_dev);
 		return -EINVAL;
+	}
 
 	lowpan_dev_info(dev)->real_dev = real_dev;
 	lowpan_dev_info(dev)->fragment_tag = 0;
