From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v2 7/9] net: mvmdio: Use devm_* API to simplify the code
Date: Fri, 16 May 2014 20:48:36 -0300
Message-ID: <20140516234835.GA2179@arch.cereza>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1399396858-14551-8-git-send-email-ezequiel.garcia@free-electrons.com>
 <53692366.4000600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:43883 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755701AbaEPXtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 19:49:12 -0400
Content-Disposition: inline
In-Reply-To: <53692366.4000600@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06 May 10:01 PM, Sergei Shtylyov wrote:
> On 05/06/2014 09:20 PM, Ezequiel Garcia wrote:
>=20
> >This commit makes use of devm_kmalloc() for memory allocation and th=
e
> >recently introduced devm_mdiobus_alloc() API to simplify driver's co=
de.
> >While here, remove a redundant out of memory error message.
>=20
> >Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> >Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> >---
> >  drivers/net/ethernet/marvell/mvmdio.c | 18 ++++++------------
> >  1 file changed, 6 insertions(+), 12 deletions(-)
>=20
> >diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/eth=
ernet/marvell/mvmdio.c
> >index b161a52..995e182 100644
> >--- a/drivers/net/ethernet/marvell/mvmdio.c
> >+++ b/drivers/net/ethernet/marvell/mvmdio.c
> [...]
> >@@ -208,11 +207,10 @@ static int orion_mdio_probe(struct platform_de=
vice *pdev)
> >  		 dev_name(&pdev->dev));
> >  	bus->parent =3D &pdev->dev;
> >
> >-	bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> >-	if (!bus->irq) {
> >-		mdiobus_free(bus);
> >+	bus->irq =3D devm_kmalloc(&pdev->dev,
> >+				sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
>=20
>    I'd rather use devm_kmalloc_array().
>=20

Sure. I'll prepare another version.

Thanks,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
