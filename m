From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 13/15] ieee802154: don't export static symbol
Date: Wed, 11 Mar 2015 17:56:35 +0100
Message-ID: <1426092997-30605-14-git-send-email-Julia.Lawall@lip6.fr>
References: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The semantic patch that fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
type T;
identifier f;
@@

static T f (...) { ... }

@@
identifier r.f;
declarer name EXPORT_SYMBOL;
@@

-EXPORT_SYMBOL(f);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ieee802154/nl-mac.c |    1 -
 1 file changed, 1 deletion(-)

diff -u -p a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -76,7 +76,6 @@ nla_put_failure:
 	nlmsg_free(msg);
 	return -ENOBUFS;
 }
-EXPORT_SYMBOL(ieee802154_nl_start_confirm);
 
 static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 				    u32 seq, int flags, struct net_device *dev)
