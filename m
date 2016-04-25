From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 09:52:41 +0200
Message-ID: <1461570761-12187-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_bridge=
_join=E2=80=99:
drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 may be=
 used uninitialized in this function

If netdev_notifier_changeupper_info.upper_dev is ever NULL, the bridge
parameter will be NULL too, and the function will return an
uninitialized value.

Pre-initialize err to zero to fix this.

=46ixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same default=
 FDB")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Can this actually happen?
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a2904029cccc2949..5e572b3510b9483a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2181,7 +2181,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch =
*ds, int port,
 			       struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps =3D ds_to_priv(ds);
-	int i, err;
+	int i, err =3D 0;
=20
 	mutex_lock(&ps->smi_mutex);
=20
--=20
1.9.1
