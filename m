From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 4/5] net: mvmdio: allow Device Tree and platform device to coexist
Date: Tue, 29 Jan 2013 21:41:45 +0100
Message-ID: <201301292141.45931.florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org> <1359473048-26551-5-git-send-email-florian@openwrt.org> <20130129175912.GE25646@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-arm-kernel@lists.infradead.org,
	Rob Landley <rob@landley.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130129175912.GE25646@obsidianresearch.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 29 janvier 2013 18:59:12, Jason Gunthorpe a =E9crit :
> On Tue, Jan 29, 2013 at 04:24:07PM +0100, Florian Fainelli wrote:
> > -	dev->err_interrupt =3D irq_of_parse_and_map(pdev->dev.of_node, 0)=
;
> > +	if (pdev->dev.of_node) {
> > +		dev->regs =3D of_iomap(pdev->dev.of_node, 0);
> > +		if (!dev->regs) {
> > +			dev_err(&pdev->dev, "No SMI register address given in=20
DT\n");
> > +			ret =3D -ENODEV;
> > +			goto out_free;
> > +		}
> > +
> > +		dev->err_interrupt =3D irq_of_parse_and_map(pdev->dev.of_node, 0=
);
> > +	} else {
> > +		r =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +
> > +		dev->regs =3D ioremap(r->start, resource_size(r));
> > +		if (!dev->regs) {
> > +			dev_err(&pdev->dev, "No SMI register address given\n");
> > +			ret =3D -ENODEV;
> > +			goto out_free;
> > +		}
> > +
> > +		dev->err_interrupt =3D platform_get_irq(pdev, 0);
> > +	}
>=20
> Why do you have these different paths for OF and platform? AFAIK thes=
e
> days when a OF device is automatically converted into a platform
> device all the struct resources are created too, so you can't you jus=
t
> use platform_get_resource and devm_request_and_ioremap for both flows=
?
>=20
> Ditto for the interrupt - platform_get_irq should work in both cases?

There was no particular reason and I updated the patchset to do that pr=
ecisely=20
in version 2.
--=20
=46lorian
