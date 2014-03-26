From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH] ixen-netback: fix trivial printf format build warning
Date: Wed, 26 Mar 2014 12:56:50 +0900
Message-ID: <1395806210-23528-1-git-send-email-sj38.park@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>
To: trivial@kernel.org, ian.campbell@citrix.com, wei.liu2@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix following trivial build warning:

drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_deall=
oc_action=E2=80=99:
drivers/net/xen-netback/netback.c:1585:8: warning:
format =E2=80=98%x=E2=80=99 expects argument of type
 =E2=80=98unsigned int=E2=80=99, but argument 3 has type =E2=80=98long =
int=E2=80=99 [-Wformat=3D]
        gop - vif->tx_unmap_ops, ret);
        ^

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 drivers/net/xen-netback/netback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 5a8c4a4..90001b3 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1574,7 +1574,7 @@ static inline void xenvif_tx_dealloc_action(struc=
t xenvif *vif)
 					vif->pages_to_unmap,
 					gop - vif->tx_unmap_ops);
 		if (ret) {
-			netdev_err(vif->dev, "Unmap fail: nr_ops %x ret %d\n",
+			netdev_err(vif->dev, "Unmap fail: nr_ops %lx ret %d\n",
 				   gop - vif->tx_unmap_ops, ret);
 			for (i =3D 0; i < gop - vif->tx_unmap_ops; ++i) {
 				if (gop[i].status !=3D GNTST_okay)
--=20
1.8.3.2
