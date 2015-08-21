From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Sat, 22 Aug 2015 00:07:56 +0200
Message-ID: <20150821220756.GI19683@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3O1VwFp74L81IIeR"
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:37850 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbHUWH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 18:07:59 -0400
Content-Disposition: inline
In-Reply-To: <20150821193926.GA16437@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3O1VwFp74L81IIeR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 21 21:39, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
> > index f790f61..f26a48d 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> [...]
> > @@ -2179,6 +2191,47 @@ static int rtl8169_get_sset_count(struct net_dev=
ice *dev, int sset)
> >  	}
> >  }
> > =20
> > +DECLARE_RTL_COND(rtl_reset_counters_cond)
> > +{
> > +	void __iomem *ioaddr =3D tp->mmio_addr;
> > +
> > +	return RTL_R32(CounterAddrLow) & CounterReset;
> > +}
> > +
> > +static void rtl8169_reset_counters(struct net_device *dev)
> > +{
>=20
> rtl8169_reset_counters duplicates most of rtl8169_update_counters. Please
> factor out the dma_alloc + parametrized CounterAddrLow write + cleanup.

Ok, will do.

> > +	rtl8169_reset_counters(dev);
> > +
> > +	rtl8169_update_counters(dev);
>=20
>=20
> The code should propagate failure when both rtl8169_reset_counters and
> rtl8169_update_counters fail.

This one I don't understand.  Neither failing to reset the counters nor
failing to update the counters is fatal for the driver.  So far the
(unchanged) rtl8169_update_counters doesn't even print a log message,
while a failing reset in rtl8169_reset_counters now does.

Why is that not sufficent?


Thanks,
Corinna

--3O1VwFp74L81IIeR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV16E8AAoJEPU2Bp2uRE+gj3IP/2Li0lqTcmvg4fSQqSPqjWb4
Lzz8aq9Auv8liFlwxDSx7Z6m9c/nhbxp8tEO2OvEGHmg+m2PiVW18h3iVlnrRxHr
gLS8vbd5WkzfTednACzGac8w5/MHVvMCwhJ2Kq9qNlXdaMg1OgS0a72dXnNDJnbe
IufKrw1wevxYd57WuvREGHOLHb3SaiKD7yP6paC60594PZHVFeEgElVMKoqFuvsM
Av0qu5+WCT9ZsGHMQhY+xUfZtNlXxPxpr5gymKDoTYW+8zODfK6rERljQ8xnlVdw
CGScj7a3Ay3wBaod3p1SEA92EYEsj3btMKw2NHAnHNsysxzq6ZDuVfIy4vJx9HtH
4eA+JlY449QvGvx/6aorXiOu5PATpF0DeD3WPqYQ4/AdyF54l2NzTQ5OV3DQ2Pay
XluwGi42crpSex+V4kadz/6TcpL7eIEvs65qUl3gOM560RgsqMu0uEyFF0K/yKkB
C/DooyRg8f3dqenMd5uDUHfS88VfBMPg+JNerjzeGmyWjMGN77dys5wJVwapOTQC
z5Ysa7YAKtlxhBRjLl9ZsEozw5kDXb7ULoniMZXgtcHdSO6/MD7YE7aG0ka2VF/m
RRiZooQsrmoAZHdm6mJ/nvuEN4XhI3KXmkax0WKv9G6ntgJAnmBKF2IDkgls1UE9
/cBx0yAycrZP4klP5ox0
=pZpx
-----END PGP SIGNATURE-----

--3O1VwFp74L81IIeR--
