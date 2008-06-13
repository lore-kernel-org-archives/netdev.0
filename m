From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: dm9000: Remove the 2 resources probe scheme.
Date: Fri, 13 Jun 2008 14:58:55 +0200
Message-ID: <200806131458.58410.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart20227509.4Z4poBElzS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:5026 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755354AbYFMM7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 08:59:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart20227509.4Z4poBElzS
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

The dm9000 driver accepts either 2 or 3 resources to describe the platform
devices. The 2 resources case abuses the ioresource mechanism by passing
ioremap()ed memory through the platform device resources. This patch removes
that case and converts boards that were using it to the 3 resources scheme.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
=2D--
 arch/blackfin/mach-bf527/boards/ezkit.c         |    7 ++-
 arch/blackfin/mach-bf533/boards/H8606.c         |    7 ++-
 arch/blackfin/mach-bf537/boards/generic_board.c |    7 ++-
 arch/blackfin/mach-bf537/boards/stamp.c         |    7 ++-
 drivers/net/dm9000.c                            |  104 +++++++++----------=
=2D--
 5 files changed, 67 insertions(+), 65 deletions(-)

diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/mach-b=
f527/boards/ezkit.c
index 5958eec..689b69c 100644
=2D-- a/arch/blackfin/mach-bf527/boards/ezkit.c
+++ b/arch/blackfin/mach-bf527/boards/ezkit.c
@@ -323,10 +323,15 @@ static struct platform_device smc91x_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x203FB800,
=2D		.end	=3D 0x203FB800 + 8,
+		.end	=3D 0x203FB800 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x203FB800 + 4,
+		.end	=3D 0x203FB800 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF9,
 		.end	=3D IRQ_PF9,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf533/boards/H8606.c b/arch/blackfin/mach-b=
f533/boards/H8606.c
index 7cc4864..4103a97 100644
=2D-- a/arch/blackfin/mach-bf533/boards/H8606.c
+++ b/arch/blackfin/mach-bf533/boards/H8606.c
@@ -65,10 +65,15 @@ static struct platform_device rtc_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x20300000,
=2D		.end	=3D 0x20300000 + 8,
+		.end	=3D 0x20300000 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x20300000 + 4,
+		.end	=3D 0x20300000 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF10,
 		.end	=3D IRQ_PF10,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf537/boards/generic_board.c b/arch/blackfi=
n/mach-bf537/boards/generic_board.c
index 7d25082..01b63e2 100644
=2D-- a/arch/blackfin/mach-bf537/boards/generic_board.c
+++ b/arch/blackfin/mach-bf537/boards/generic_board.c
@@ -166,10 +166,15 @@ static struct platform_device smc91x_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x203FB800,
=2D		.end	=3D 0x203FB800 + 8,
+		.end	=3D 0x203FB800 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x203FB800 + 4,
+		.end	=3D 0x203FB800 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF9,
 		.end	=3D IRQ_PF9,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/arch/blackfin/mach-bf537/boards/stamp.c b/arch/blackfin/mach-b=
f537/boards/stamp.c
index 671f9d6..16dfeaf 100644
=2D-- a/arch/blackfin/mach-bf537/boards/stamp.c
+++ b/arch/blackfin/mach-bf537/boards/stamp.c
@@ -205,10 +205,15 @@ static struct platform_device smc91x_device =3D {
 static struct resource dm9000_resources[] =3D {
 	[0] =3D {
 		.start	=3D 0x203FB800,
=2D		.end	=3D 0x203FB800 + 8,
+		.end	=3D 0x203FB800 + 1,
 		.flags	=3D IORESOURCE_MEM,
 	},
 	[1] =3D {
+		.start	=3D 0x203FB800 + 4,
+		.end	=3D 0x203FB800 + 5,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
 		.start	=3D IRQ_PF9,
 		.end	=3D IRQ_PF9,
 		.flags	=3D (IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE),
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 6bc8924..fca7831 100644
=2D-- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
 	const unsigned char *mac_src;
=2D	unsigned long base;
 	int ret =3D 0;
 	int iosize;
 	int i;
@@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
 	if (pdev->num_resources < 2) {
 		ret =3D -ENODEV;
 		goto out;
=2D	} else if (pdev->num_resources =3D=3D 2) {
=2D		base =3D pdev->resource[0].start;
=2D
=2D		if (!request_mem_region(base, 4, ndev->name)) {
=2D			ret =3D -EBUSY;
=2D			goto out;
=2D		}
=2D
=2D		ndev->base_addr =3D base;
=2D		ndev->irq =3D pdev->resource[1].start;
=2D		db->io_addr =3D (void __iomem *)base;
=2D		db->io_data =3D (void __iomem *)(base + 4);
+	}
=20
=2D		/* ensure at least we have a default set of IO routines */
=2D		dm9000_set_io(db, 2);
+	db->addr_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	db->data_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	db->irq_res  =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
=20
=2D	} else {
=2D		db->addr_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
=2D		db->data_res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
=2D		db->irq_res  =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
=2D
=2D		if (db->addr_res =3D=3D NULL || db->data_res =3D=3D NULL ||
=2D		    db->irq_res =3D=3D NULL) {
=2D			dev_err(db->dev, "insufficient resources\n");
=2D			ret =3D -ENOENT;
=2D			goto out;
=2D		}
+	if (db->addr_res =3D=3D NULL || db->data_res =3D=3D NULL ||
+	    db->irq_res =3D=3D NULL) {
+		dev_err(db->dev, "insufficient resources\n");
+		ret =3D -ENOENT;
+		goto out;
+	}
=20
=2D		i =3D res_size(db->addr_res);
=2D		db->addr_req =3D request_mem_region(db->addr_res->start, i,
=2D						  pdev->name);
+	iosize =3D res_size(db->addr_res);
+	db->addr_req =3D request_mem_region(db->addr_res->start, iosize,
+					  pdev->name);
=20
=2D		if (db->addr_req =3D=3D NULL) {
=2D			dev_err(db->dev, "cannot claim address reg area\n");
=2D			ret =3D -EIO;
=2D			goto out;
=2D		}
=2D
=2D		db->io_addr =3D ioremap(db->addr_res->start, i);
+	if (db->addr_req =3D=3D NULL) {
+		dev_err(db->dev, "cannot claim address reg area\n");
+		ret =3D -EIO;
+		goto out;
+	}
=20
=2D		if (db->io_addr =3D=3D NULL) {
=2D			dev_err(db->dev, "failed to ioremap address reg\n");
=2D			ret =3D -EINVAL;
=2D			goto out;
=2D		}
+	db->io_addr =3D ioremap(db->addr_res->start, iosize);
=20
=2D		iosize =3D res_size(db->data_res);
=2D		db->data_req =3D request_mem_region(db->data_res->start, iosize,
=2D						  pdev->name);
+	if (db->io_addr =3D=3D NULL) {
+		dev_err(db->dev, "failed to ioremap address reg\n");
+		ret =3D -EINVAL;
+		goto out;
+	}
=20
=2D		if (db->data_req =3D=3D NULL) {
=2D			dev_err(db->dev, "cannot claim data reg area\n");
=2D			ret =3D -EIO;
=2D			goto out;
=2D		}
+	iosize =3D res_size(db->data_res);
+	db->data_req =3D request_mem_region(db->data_res->start, iosize,
+					  pdev->name);
=20
=2D		db->io_data =3D ioremap(db->data_res->start, iosize);
+	if (db->data_req =3D=3D NULL) {
+		dev_err(db->dev, "cannot claim data reg area\n");
+		ret =3D -EIO;
+		goto out;
+	}
=20
=2D		if (db->io_data =3D=3D NULL) {
=2D			dev_err(db->dev,"failed to ioremap data reg\n");
=2D			ret =3D -EINVAL;
=2D			goto out;
=2D		}
+	db->io_data =3D ioremap(db->data_res->start, iosize);
=20
=2D		/* fill in parameters for net-dev structure */
+	if (db->io_data =3D=3D NULL) {
+		dev_err(db->dev,"failed to ioremap data reg\n");
+		ret =3D -EINVAL;
+		goto out;
+	}
=20
=2D		ndev->base_addr =3D (unsigned long)db->io_addr;
=2D		ndev->irq	=3D db->irq_res->start;
+	/* fill in parameters for net-dev structure */
+	ndev->base_addr =3D (unsigned long)db->io_addr;
+	ndev->irq	=3D db->irq_res->start;
=20
=2D		/* ensure at least we have a default set of IO routines */
=2D		dm9000_set_io(db, iosize);
=2D	}
+	/* ensure at least we have a default set of IO routines */
+	dm9000_set_io(db, iosize);
=20
 	/* check to see if anything is being over-ridden */
 	if (pdata !=3D NULL) {
=2D-=20
1.5.0


=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart20227509.4Z4poBElzS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIUm8S8y9gWxC9vpcRAn2XAKDAa+9Ej/HakXNX881dZJBAk9X6qgCfTv47
RlOu7O6ggnkWbHlP8LNrDmU=
=5ccK
-----END PGP SIGNATURE-----

--nextPart20227509.4Z4poBElzS--
