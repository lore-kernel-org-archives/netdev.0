From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] cxgb4: fix usage of uninitialized variable
Date: Fri, 4 Sep 2015 23:05:42 +0200
Message-ID: <20150904210542.GA785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57058 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933784AbbIDVGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 17:06:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function =E2=80=98i=
nit_one=E2=80=99:
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4579:8: warning: =E2=80=
=98chip=E2=80=99 may be used uninitialized in this function [-Wmaybe-un=
initialized]
   chip |=3D CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
        ^
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4571:11: note: =E2=80=98=
chip=E2=80=99 was declared here
  int ver, chip;
           ^

=46ixes: d86bd29e0b31 ("cxgb4/cxgb4vf: read the correct bits of PL Who =
Am I register")
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>
---

 Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b677667=
83a8.

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/=
net/ethernet/chelsio/cxgb4/cxgb4_main.c
index eb22d58..592a4d6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4568,28 +4568,23 @@ static void free_some_resources(struct adapter =
*adapter)
=20
 static int get_chip_type(struct pci_dev *pdev, u32 pl_rev)
 {
-	int ver, chip;
 	u16 device_id;
=20
 	/* Retrieve adapter's device ID */
 	pci_read_config_word(pdev, PCI_DEVICE_ID, &device_id);
-	ver =3D device_id >> 12;
-	switch (ver) {
+
+	switch (device_id >> 12) {
 	case CHELSIO_T4:
-		chip |=3D CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
-		break;
+		return CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
 	case CHELSIO_T5:
-		chip |=3D CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
-		break;
+		return CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
 	case CHELSIO_T6:
-		chip |=3D CHELSIO_CHIP_CODE(CHELSIO_T6, pl_rev);
-		break;
+		return CHELSIO_CHIP_CODE(CHELSIO_T6, pl_rev);
 	default:
 		dev_err(&pdev->dev, "Device %d is not supported\n",
 			device_id);
-		return -EINVAL;
 	}
-	return chip;
+	return -EINVAL;
 }
=20
 static int init_one(struct pci_dev *pdev, const struct pci_device_id *=
ent)
--=20
2.4.3
