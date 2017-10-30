From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: caif: chnl_net: remove unnecessary null check in
 chnl_recv_cb
Date: Mon, 30 Oct 2017 17:47:14 -0500
Message-ID: <20171030224714.GA31045@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

container_of is never null, so this null check is unnecessary.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/caif/chnl_net.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 922ac1d..489298d 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -77,8 +77,6 @@ static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 	u8 buf;
 
 	priv = container_of(layr, struct chnl_net, chnl);
-	if (!priv)
-		return -EINVAL;
 
 	skb = (struct sk_buff *) cfpkt_tonative(pkt);
 
-- 
2.7.4
