From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH] bfin_mac: fix memleak in mii_bus{probe|remove}
Date: Tue, 18 May 2010 15:34:46 +0400
Message-ID: <20100518113445.GA28386@coldcone>
References: <20100518092839.GA21791@coldcone>
 <AANLkTikcB3f0KmkcnDsV46Xrpm3WcCLQklxbLSJfMTlW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, michael.hennerich@analog.com,
	cooloney@kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34018 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab0ERLcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:32:55 -0400
Received: by fxm10 with SMTP id 10so963180fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 04:32:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTikcB3f0KmkcnDsV46Xrpm3WcCLQklxbLSJfMTlW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 18, 2010 at 18:05 +0800, Sonic Zhang wrote:
> 2010/5/18 Denis Kirjanov <kirjanov@gmail.com <kirjanov@gmail.com>:
> > Fix memory leak with miibus->irq
> >
> > Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> > ---
> >
> > drivers/net/bfin_mac.c | =9A =9A2 ++
> > =9A1 files changed, 2 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> > index 39a54ba..7a17b8a 100644
> > --- a/drivers/net/bfin_mac.c
> > +++ b/drivers/net/bfin_mac.c
> > @@ -1627,6 +1627,7 @@ static int __devinit bfin_mii_bus_probe(struc=
t platform_device *pdev)
> >
> > =9Aout_err_mdiobus_register:
> > =9A =9A =9A =9Amdiobus_free(miibus);
> > + =9A =9A =9A kfree(miibus->irq);
>=20
> Should you move this kfree before mdiobus_free?
>=20
> > =9Aout_err_alloc:
> > =9A =9A =9A =9Aperipheral_free_list(pin_req);
> >
> > @@ -1638,6 +1639,7 @@ static int __devexit bfin_mii_bus_remove(stru=
ct platform_device *pdev)
> > =9A =9A =9A =9Astruct mii_bus *miibus =3D platform_get_drvdata(pdev=
);
> > =9A =9A =9A =9Aplatform_set_drvdata(pdev, NULL);
> > =9A =9A =9A =9Amdiobus_unregister(miibus);
> > + =9A =9A =9A kfree(miibus->irq);
> > =9A =9A =9A =9Amdiobus_free(miibus);
> > =9A =9A =9A =9Aperipheral_free_list(pin_req);
> > =9A =9A =9A =9Areturn 0;
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =9Ahttp://vger.kernel.org/majordomo-info.htm=
l
> >
Oops, yeah, fixed.
Thanks.

[PATCH] bfin_mac: fix memleak in mii_bus_{probe|remove}
=46ix memory leak with miibus->irq

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/bfin_mac.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 39a54ba..368f333 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1626,6 +1626,7 @@ static int __devinit bfin_mii_bus_probe(struct pl=
atform_device *pdev)
 	return 0;
=20
 out_err_mdiobus_register:
+	kfree(miibus->irq);
 	mdiobus_free(miibus);
 out_err_alloc:
 	peripheral_free_list(pin_req);
@@ -1638,6 +1639,7 @@ static int __devexit bfin_mii_bus_remove(struct p=
latform_device *pdev)
 	struct mii_bus *miibus =3D platform_get_drvdata(pdev);
 	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
+	kfree(miibus->irq);
 	mdiobus_free(miibus);
 	peripheral_free_list(pin_req);
 	return 0;

