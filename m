From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 17/21] orinoco_pci: use pci_iomap() for resources
Date: Fri, 07 Apr 2006 04:10:53 -0400
Message-ID: <20060407081053.16107.19347.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_pci.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/or=
inoco_pci.c
index e57e92b..75df90f 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -170,9 +170,7 @@ static int orinoco_pci_init_one(struct p
 				const struct pci_device_id *ent)
 {
 	int err =3D 0;
-	unsigned long pci_iorange;
-	u16 __iomem *pci_ioaddr =3D NULL;
-	unsigned long pci_iolen;
+	void __iomem *pci_ioaddr =3D NULL;
 	struct orinoco_private *priv =3D NULL;
 	struct orinoco_pci_card *card;
 	struct net_device *dev =3D NULL;
@@ -190,10 +188,9 @@ static int orinoco_pci_init_one(struct p
 	}
=20
 	/* Resource 0 is mapped to the hermes registers */
-	pci_iorange =3D pci_resource_start(pdev, 0);
-	pci_iolen =3D pci_resource_len(pdev, 0);
-	pci_ioaddr =3D ioremap(pci_iorange, pci_iolen);
-	if (!pci_iorange) {
+	pci_ioaddr =3D pci_iomap(pdev, 0, 0);
+	if (!pci_ioaddr) {
+		err =3D -EIO;
 		printk(KERN_ERR PFX "Cannot remap hardware registers\n");
 		goto fail_map;
 	}
@@ -208,8 +205,8 @@ static int orinoco_pci_init_one(struct p
 	priv =3D netdev_priv(dev);
 	card =3D priv->card;
 	card->pci_ioaddr =3D pci_ioaddr;
-	dev->mem_start =3D pci_iorange;
-	dev->mem_end =3D pci_iorange + pci_iolen - 1;
+	dev->mem_start =3D pci_resource_start(pdev, 0);
+	dev->mem_end =3D dev->mem_start + pci_resource_len(pdev, 0) - 1;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
=20



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
