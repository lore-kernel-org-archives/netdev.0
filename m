From: Jan Moskyto Matejka <mq@suse.cz>
Subject: [PATCH] net: via-rhine: fix compiler warning
Date: Tue, 29 Apr 2014 19:36:11 +0200
Message-ID: <1398792971-10379-1-git-send-email-mq@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Moskyto Matejka <mq@suse.cz>
To: Alexey Charkov <alchark@gmail.com>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixed different size cast warning:

	drivers/net/ethernet/via/via-rhine.c: In function =E2=80=98rhine_init_=
one_platform=E2=80=99:
	drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast from point=
er to integer of different size [-Wpointer-to-int-cast]
	  revision =3D (u32)match->data;
		     ^

That code was added in commit 2d283862dc62daead9db0dc89cd0d0351e91f765
("net: via-rhine: add OF bus binding").

Signed-off-by: Jan Moskyto Matejka <mq@suse.cz>
---
 drivers/net/ethernet/via/via-rhine.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/etherne=
t/via/via-rhine.c
index 4fa9201..76d18e0 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -288,7 +288,7 @@ MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
  * (for quirks etc.)
  */
 static struct of_device_id rhine_of_tbl[] =3D {
-	{ .compatible =3D "via,vt8500-rhine", .data =3D (void *)0x84 },
+	{ .compatible =3D "via,vt8500-rhine", .data =3D (u32 []) { 0x84 } },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(of, rhine_of_tbl);
@@ -1129,7 +1129,7 @@ static int rhine_init_one_platform(struct platfor=
m_device *pdev)
 	if (!irq)
 		return -EINVAL;
=20
-	revision =3D (u32)match->data;
+	revision =3D *((u32 *) match->data);
 	if (!revision)
 		return -EINVAL;
=20
--=20
1.8.4.5
