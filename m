From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH 3/4] dpaa_eth: change device used
Date: Thu, 12 Oct 2017 09:11:02 +0000
Message-ID: <DB3PR0402MB3849646B999712EE93DC9207EC4B0@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1507644618-32006-1-git-send-email-madalin.bucur@nxp.com>
        <1507644618-32006-4-git-send-email-madalin.bucur@nxp.com>
 <20171011.140203.578840078366210432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "junote@outlook.com" <junote@outlook.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011.140203.578840078366210432.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 12, 2017 12:02 AM
> To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Subject: Re: [PATCH 3/4] dpaa_eth: change device used
>=20
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Tue, 10 Oct 2017 17:10:17 +0300
>=20
> > @@ -2696,7 +2681,13 @@ static int dpaa_eth_probe(struct platform_device
> *pdev)
> >  	int err =3D 0, i, channel;
> >  	struct device *dev;
> >
> > -	dev =3D &pdev->dev;
> > +	/* device used for DMA mapping */
> > +	dev =3D pdev->dev.parent;
> > +	err =3D dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(40));
> > +	if (err) {
> > +		dev_err(dev, "dma_coerce_mask_and_coherent() failed\n");
> > +		goto dev_mask_failed;
> > +	}
> >
> >  	/* Allocate this early, so we can store relevant information in
> >  	 * the private area
>=20
> Since you are moving this code up before the netdev allocation, you must
> adjust the failure path goto label used.
>=20
> Your change as-is will cause an OOPS because we'll pass a NULL pointer
> to free_netdev().

Thank you, besides this new issue I was introducing I see there other probl=
ems,
I'll include a cleanup of these error paths in v2.

Madalin
