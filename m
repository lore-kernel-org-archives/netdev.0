From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net/at91_ether: prepare and unprepare clock
Date: Mon, 12 Jan 2015 12:08:18 +0100
Message-ID: <20150112110818.GJ2447@piout.net>
References: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
 <54AE623E.5020507@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:52710 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751639AbbALLIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 06:08:20 -0500
Content-Disposition: inline
In-Reply-To: <54AE623E.5020507@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is actually a fix for 3.19, can you take it for the next rc ?

Thanks!

On 08/01/2015 at 11:55:58 +0100, Nicolas Ferre wrote :
> Le 07/01/2015 23:59, Alexandre Belloni a =E9crit :
> > The clock is enabled without being prepared, this leads to:
> >=20
> > WARNING: CPU: 0 PID: 1 at drivers/clk/clk.c:889 __clk_enable+0x24/0=
xa8()
> >=20
> > and a non working ethernet interface.
> >=20
> > Use clk_prepare_enable() and clk_disable_unprepare() to handle the =
clock.
> >=20
> > Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.=
com>
>=20
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>=20
> > ---
> >  drivers/net/ethernet/cadence/at91_ether.c | 10 +++++-----
> >  1 file changed, 5 insertions(+), 5 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/ne=
t/ethernet/cadence/at91_ether.c
> > index 55eb7f2af2b4..7ef55f5fa664 100644
> > --- a/drivers/net/ethernet/cadence/at91_ether.c
> > +++ b/drivers/net/ethernet/cadence/at91_ether.c
> > @@ -340,7 +340,7 @@ static int __init at91ether_probe(struct platfo=
rm_device *pdev)
> >  		res =3D PTR_ERR(lp->pclk);
> >  		goto err_free_dev;
> >  	}
> > -	clk_enable(lp->pclk);
> > +	clk_prepare_enable(lp->pclk);
> > =20
> >  	lp->hclk =3D ERR_PTR(-ENOENT);
> >  	lp->tx_clk =3D ERR_PTR(-ENOENT);
> > @@ -406,7 +406,7 @@ static int __init at91ether_probe(struct platfo=
rm_device *pdev)
> >  err_out_unregister_netdev:
> >  	unregister_netdev(dev);
> >  err_disable_clock:
> > -	clk_disable(lp->pclk);
> > +	clk_disable_unprepare(lp->pclk);
> >  err_free_dev:
> >  	free_netdev(dev);
> >  	return res;
> > @@ -424,7 +424,7 @@ static int at91ether_remove(struct platform_dev=
ice *pdev)
> >  	kfree(lp->mii_bus->irq);
> >  	mdiobus_free(lp->mii_bus);
> >  	unregister_netdev(dev);
> > -	clk_disable(lp->pclk);
> > +	clk_disable_unprepare(lp->pclk);
> >  	free_netdev(dev);
> > =20
> >  	return 0;
> > @@ -440,7 +440,7 @@ static int at91ether_suspend(struct platform_de=
vice *pdev, pm_message_t mesg)
> >  		netif_stop_queue(net_dev);
> >  		netif_device_detach(net_dev);
> > =20
> > -		clk_disable(lp->pclk);
> > +		clk_disable_unprepare(lp->pclk);
> >  	}
> >  	return 0;
> >  }
> > @@ -451,7 +451,7 @@ static int at91ether_resume(struct platform_dev=
ice *pdev)
> >  	struct macb *lp =3D netdev_priv(net_dev);
> > =20
> >  	if (netif_running(net_dev)) {
> > -		clk_enable(lp->pclk);
> > +		clk_prepare_enable(lp->pclk);
> > =20
> >  		netif_device_attach(net_dev);
> >  		netif_start_queue(net_dev);
> >=20
>=20
>=20
> --=20
> Nicolas Ferre

--=20
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
