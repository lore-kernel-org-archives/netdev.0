From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mlxsw: spectrum_router: Return -ENOENT in case of error
Date: Thu, 14 Jul 2016 08:18:45 +0200
Message-ID: <1468477125-3153-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: jiri@mellanox.com, idosch@mellanox.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'vr' should be a valid pointer here, so returning 'PTR_ERR(vr)' is wron=
g.
Return an explicit error code (-ENOENT) instead.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/dr=
ivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e084ea5..81418d6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1803,7 +1803,7 @@ int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port=
 *mlxsw_sp_port,
 					      sizeof(fib4->dst), fib4->dst_len);
 	if (!fib_entry) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being r=
emoved.\n");
-		return PTR_ERR(vr);
+		return -ENOENT;
 	}
 	mlxsw_sp_fib_entry_del(mlxsw_sp_port->mlxsw_sp, fib_entry);
 	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
--=20
2.7.4


---
L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=
=C3=A9rifi=C3=A9e par le logiciel antivirus Avast.
https://www.avast.com/antivirus

--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
