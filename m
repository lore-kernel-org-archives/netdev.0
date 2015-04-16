From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: dsa: mv88e6xxx: Add missing initialization in mv88e6xxx_set_port_state()
Date: Thu, 16 Apr 2015 20:49:14 +0200
Message-ID: <1429210154-21805-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:59455 "EHLO
	baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbbDPStJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:49:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_set_port_st=
ate=E2=80=99:
drivers/net/dsa/mv88e6xxx.c:905: warning: =E2=80=98ret=E2=80=99 may be =
used uninitialized in this function

If oldstate =3D=3D state, mv88e6xxx_set_port_state() will return an
uninitialized value. Pre-initialize ret to zero to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f64186a5f63453f3..859a332fe5cd0251 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -902,7 +902,7 @@ static int _mv88e6xxx_flush_fid(struct dsa_switch *=
ds, int fid)
 static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u=
8 state)
 {
 	struct mv88e6xxx_priv_state *ps =3D ds_to_priv(ds);
-	int reg, ret;
+	int reg, ret =3D 0;
 	u8 oldstate;
=20
 	mutex_lock(&ps->smi_mutex);
--=20
1.9.1
