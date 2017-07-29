From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/2] l2tp: constify net_protocol structures
Date: Sat, 29 Jul 2017 08:16:56 +0200
Message-ID: <1501309016-16059-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1501309016-16059-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501309016-16059-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The net_protocol structure is only passed as the first argument to
inet_add_protocol or inet_del_protocol, both of which are declared
as const.  Thus the net_protocol structure itself can be const.

Done with the help of Coccinelle.

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct net_protocol i@p = { ... };

@ok1@
identifier r.i;
expression e1;
position p;
@@
 \(inet_add_protocol\|inet_del_protocol\)(&i@p,...)

@bad@
position p != {r.p,ok1.p};
identifier r.i;
struct net_protocol e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct net_protocol i = { ... };
// </smpl>

Also drop __read_mostly.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/l2tp/l2tp_ip.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 4d322c1..c8e4d85 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -649,7 +649,7 @@ int l2tp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	.ops		= &l2tp_ip_ops,
 };
 
-static struct net_protocol l2tp_ip_protocol __read_mostly = {
+static const struct net_protocol l2tp_ip_protocol = {
 	.handler	= l2tp_ip_recv,
 	.netns_ok	= 1,
 };
