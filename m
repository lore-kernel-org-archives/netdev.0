From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pinctrl tree with Linus' tree
Date: Mon, 17 Jun 2013 16:11:27 +1000
Message-ID: <20130617161127.f202c6abe603c9ff8b30fc7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Jun_2013_16_11_27_+1000_.B8raeU5yTFdP/DH"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:33443 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab3FQGLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 02:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__17_Jun_2013_16_11_27_+1000_.B8raeU5yTFdP/DH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Today's linux-next merge of the pinctrl tree got a conflict in
drivers/net/ethernet/ti/davinci_mdio.c between commit 2786aae7fc93
("net/ti davinci_mdio: don't hold a spin lock while calling pm_runtime")
from Linus' tree and commit 5c0e3580cb98 ("drivers: net: davinci_mdio:
use pinctrl PM helpers") from the pinctrl tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/ti/davinci_mdio.c
index c47f0db,5e361f4..0000000
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@@ -449,22 -453,32 +453,28 @@@ static int davinci_mdio_suspend(struct=20
  	__raw_writel(ctrl, &data->regs->control);
  	wait_for_idle(data);
 =20
 -	pm_runtime_put_sync(data->dev);
 -
  	data->suspended =3D true;
  	spin_unlock(&data->lock);
 +	pm_runtime_put_sync(data->dev);
 =20
+ 	/* Select sleep pin state */
+ 	pinctrl_pm_select_sleep_state(dev);
+=20
  	return 0;
  }
 =20
  static int davinci_mdio_resume(struct device *dev)
  {
  	struct davinci_mdio_data *data =3D dev_get_drvdata(dev);
 -	u32 ctrl;
 =20
+ 	/* Select default pin state */
+ 	pinctrl_pm_select_default_state(dev);
+=20
 -	spin_lock(&data->lock);
  	pm_runtime_get_sync(data->dev);
 =20
 +	spin_lock(&data->lock);
  	/* restart the scan state machine */
 -	ctrl =3D __raw_readl(&data->regs->control);
 -	ctrl |=3D CONTROL_ENABLE;
 -	__raw_writel(ctrl, &data->regs->control);
 +	__davinci_mdio_reset(data);
 =20
  	data->suspended =3D false;
  	spin_unlock(&data->lock);

--Signature=_Mon__17_Jun_2013_16_11_27_+1000_.B8raeU5yTFdP/DH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRvqiUAAoJEECxmPOUX5FE5ZsQAIqtVeZEvVCGM52tpmSA7cEs
FiKEjhQTRHkHOpvPr2QcWVqV61tkaj4AkSDZ2lAinhEWMyrgK73cTn7o6JL0Ser+
KAbSO9hdBqUExflil6ljkPal6s2pMckdpsfJoQXYs5iOZ/TLwEdmJEVXlqmL5Y0L
/56fF/z/9TXZBiNi5/EzaQPBvkT2EkPA0wZ+980fV9heFas7R4AcgQFCRWbnFdSI
IErvXyN1ow2hipdF+PDotFOcuPTfINjqfVYhfp3a0KI7ganG1eFC1DSeUMCV/vEC
87evLTC5qYh5vVmDEHkHPv92wlDTyRevOm2HlzCV+drSyD7kxMR1x181XYFtldJH
VYtH88KbUFJXh5duaOKIB6cMs3gmieL5abOLBBFITnG9etx2i4/uB+p+F0arhCIE
Nu1OeEyTs6C83hZYuQFDvsC5Bov4qeZTVCMKs5S13kuzHjOYcS4YK96uK8h5SmII
syljzQkLeurga7hI+qyo5jJpSKdXSOBxClQr3ZwztM3CH0dqdpOhKTtJvZ4v/YbR
fonIsjzziNhNzVGtwlmLSfA/Kz6N9MLZ9QlrXSNnLiTsuaF706FPhExKYVCydOv/
R5XNTMzVaodh5jR2zmVFwkKcXaUkL2uI1lDCcNu7s+XpfZEKOSOscFxw++5r5fB0
XFgaXroHdNmdq9rZcLDn
=32LF
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Jun_2013_16_11_27_+1000_.B8raeU5yTFdP/DH--
