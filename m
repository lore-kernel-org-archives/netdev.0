From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Thu, 24 Sep 2015 17:00:58 +0100
Message-ID: <20150924160058.GA21513@n2100.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
 <20150923.162417.814596822188458346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
	frowand.list@gmail.com, grant.likely@linaro.org,
	isubramanian@apm.com, kchudgar@apm.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, leoli@freescale.com,
	michal.simek@xilinx.com, netdev@vger.kernel.org, rric@kernel.org,
	robh+dt@kernel.org, soren.brinkmann@xilinx.com,
	sgoutham@cavium.com, thomas.petazzoni@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150923.162417.814596822188458346.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2015 at 04:24:17PM -0700, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Tue, 22 Sep 2015 17:17:10 +0100
>=20
> > This is the second version of the series, with the comments David h=
ad
> > on the first patch fixed up.  Original series description with upda=
ted
> > diffstat below.
>=20
> This needs some build fixes:
>=20
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function =E2=80=98=
xgene_enet_phy_connect=E2=80=99:
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:694:20: error: too few=
 arguments to function =E2=80=98of_phy_connect=E2=80=99
>    pdata->phy_dev =3D of_phy_connect(ndev, phy_np,
>                     ^
> In file included from drivers/net/ethernet/apm/xgene/xgene_enet_main.=
h:31:0,
>                  from drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:=
22:
> include/linux/of_mdio.h:18:27: note: declared here
>  extern struct phy_device *of_phy_connect(struct net_device *dev,
>                            ^

Sorry about that, I'll send a new series later this evening.

Unfortunately, that's also not the only one - Cavium Thunder BGX also
fails.  Looking again at that driver, the driver structure doesn't lend
itself well to having the refcount balancing added to it due to the
multiple different paths which it obtains a phy_device.  I think this i=
s
best left to the maintainers of this driver to fix, so I'm intending to
drop the change to that driver.

That's not a problem: the driver is already buggy in this regard today,
and that's won't be any different as a result of omitting it.  It's jus=
t
a shame to leave one instance unfixed.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
