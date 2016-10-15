From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] ipvlan: constify l3mdev_ops structure
Date: Sat, 15 Oct 2016 17:40:30 +0200
Message-ID: <1476546030-14324-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This l3mdev_ops structure is only stored in the l3mdev_ops field of a
net_device structure.  This field is declared const, so the l3mdev_ops
structure can be declared as const also.  Additionally drop the
__read_mostly annotation.

The semantic patch that adds const is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct l3mdev_ops i@p = { ... };

@ok@
identifier r.i;
struct net_device *e;
position p;
@@
e->l3mdev_ops = &i@p;

@bad@
position p != {r.p,ok.p};
identifier r.i;
struct l3mdev_ops e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct l3mdev_ops i = { ... };
// </smpl>

The effect on the layout of the .o file is shown by the following output
of the size command, first before then after the transformation:

   text    data     bss     dec     hex filename
   7364     466      52    7882    1eca drivers/net/ipvlan/ipvlan_main.o
   7412     434      52    7898    1eda drivers/net/ipvlan/ipvlan_main.o

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ipvlan/ipvlan_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -26,7 +26,7 @@ static struct nf_hook_ops ipvl_nfops[] _
 	},
 };
 
-static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly = {
+static const struct l3mdev_ops ipvl_l3mdev_ops = {
 	.l3mdev_l3_rcv = ipvlan_l3_rcv,
 };
 
