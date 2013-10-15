From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx4: Clean the code to eliminate trivial build warnings
Date: Tue, 15 Oct 2013 16:55:21 +0200
Message-ID: <1381848924-18992-2-git-send-email-amirv@mellanox.com>
References: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60351 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932203Ab3JOO4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:56:02 -0400
In-Reply-To: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Or Gerlitz <ogerlitz@mellanox.com>

Remove code that triggers trivial build warnings.

drivers/net/ethernet/mellanox/mlx4/cmd.c: In function =E2=80=98mlx4_set=
_vf_vlan=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/cmd.c:2256: warning: variable =E2=80=
=98vf_oper=E2=80=99 set but not used
drivers/net/ethernet/mellanox/mlx4/mcg.c: In function =E2=80=98mlx4_map=
_sw_to_hw_steering_mode=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/mcg.c:648: warning: comparison of un=
signed expression < 0 is always false
drivers/net/ethernet/mellanox/mlx4/mcg.c: In function =E2=80=98mlx4_map=
_sw_to_hw_steering_id=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/mcg.c:685: warning: comparison of un=
signed expression < 0 is always false
drivers/net/ethernet/mellanox/mlx4/mcg.c: In function =E2=80=98mlx4_hw_=
rule_sz=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/mcg.c:712: warning: comparison of un=
signed expression < 0 is always false
drivers/net/ethernet/mellanox/mlx4/fw.c: In function =E2=80=98mlx4_opre=
q_action=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/fw.c:1732: warning: variable =E2=80=98=
type_m=E2=80=99 set but not used
drivers/net/ethernet/mellanox/mlx4/srq.c:302: warning: no previous prot=
otype for =E2=80=98mlx4_srq_lookup=E2=80=99

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 --
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/srq.c | 1 +
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/eth=
ernet/mellanox/mlx4/cmd.c
index ea20182..735765c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2253,7 +2253,6 @@ EXPORT_SYMBOL_GPL(mlx4_set_vf_mac);
 int mlx4_set_vf_vlan(struct mlx4_dev *dev, int port, int vf, u16 vlan,=
 u8 qos)
 {
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
-	struct mlx4_vport_oper_state *vf_oper;
 	struct mlx4_vport_state *vf_admin;
 	int slave;
=20
@@ -2269,7 +2268,6 @@ int mlx4_set_vf_vlan(struct mlx4_dev *dev, int po=
rt, int vf, u16 vlan, u8 qos)
 		return -EINVAL;
=20
 	vf_admin =3D &priv->mfunc.master.vf_admin[slave].vport[port];
-	vf_oper =3D &priv->mfunc.master.vf_oper[slave].vport[port];
=20
 	if ((0 =3D=3D vlan) && (0 =3D=3D qos))
 		vf_admin->default_vlan =3D MLX4_VGT;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/eth=
ernet/mellanox/mlx4/mcg.c
index 55f6245..70f0213 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -645,7 +645,7 @@ static const u8 __promisc_mode[] =3D {
 int mlx4_map_sw_to_hw_steering_mode(struct mlx4_dev *dev,
 				    enum mlx4_net_trans_promisc_mode flow_type)
 {
-	if (flow_type >=3D MLX4_FS_MODE_NUM || flow_type < 0) {
+	if (flow_type >=3D MLX4_FS_MODE_NUM) {
 		mlx4_err(dev, "Invalid flow type. type =3D %d\n", flow_type);
 		return -EINVAL;
 	}
@@ -681,7 +681,7 @@ const u16 __sw_id_hw[] =3D {
 int mlx4_map_sw_to_hw_steering_id(struct mlx4_dev *dev,
 				  enum mlx4_net_trans_rule_id id)
 {
-	if (id >=3D MLX4_NET_TRANS_RULE_NUM || id < 0) {
+	if (id >=3D MLX4_NET_TRANS_RULE_NUM) {
 		mlx4_err(dev, "Invalid network rule id. id =3D %d\n", id);
 		return -EINVAL;
 	}
@@ -706,7 +706,7 @@ static const int __rule_hw_sz[] =3D {
 int mlx4_hw_rule_sz(struct mlx4_dev *dev,
 	       enum mlx4_net_trans_rule_id id)
 {
-	if (id >=3D MLX4_NET_TRANS_RULE_NUM || id < 0) {
+	if (id >=3D MLX4_NET_TRANS_RULE_NUM) {
 		mlx4_err(dev, "Invalid network rule id. id =3D %d\n", id);
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/eth=
ernet/mellanox/mlx4/srq.c
index 79fd269..9e08e35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -34,6 +34,7 @@
 #include <linux/init.h>
=20
 #include <linux/mlx4/cmd.h>
+#include <linux/mlx4/srq.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
=20
--=20
1.8.3.4
