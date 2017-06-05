From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: bridge: fix potential NULL pointer dereference
Date: Mon, 5 Jun 2017 16:30:30 -0500
Message-ID: <20170605213030.GA6272@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NULL check before dereferencing pointer _p_ inside br_afspec().

Addresses-Coverity-ID: 1401872
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/bridge/br_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1e63ec4..ad85a9c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -776,7 +776,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 			goto out;
 	}
 
-	if (afspec) {
+	if (p && afspec) {
 		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
 				afspec, RTM_SETLINK);
 	}
-- 
2.5.0
