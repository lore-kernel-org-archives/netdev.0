From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 10:55:56 -0500
Message-ID: <20160428155556.GA8333@nathan3500-linux-VM>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57222FCE.8050407@atmel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 05:44:14PM +0200, Nicolas Ferre wrote:
> Le 28/04/2016 16:46, Nathan Sullivan a =E9crit :
> > Since of_mdiobus_register and mdiobus_register will scan automatica=
lly,
> > do not manually scan for PHY devices in the macb ethernet driver. D=
oing
> > so will result in many nonexistent PHYs on the MDIO bus if the MDIO
> > lines are floating or grounded, such as when they are not used.
> >=20
> > Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
>=20
> Well, as explained in the commit message that added this feature and =
in
> the comment, if no phy is specified in the DT we end up without phy..=
=2E
>=20
> There are AT91 platforms which lack specification for the phy node in
> the DT. So, I don't know if there is a better way to deal with this c=
ase
> but I see this removal as risky.
>=20
> Bye,
>=20
> Nicolas Ferre

Hmm, are AT91 platforms special in this regard? As far as I can tell, t=
his
driver (macb) and Marvell PXA are the only ethernet drivers that call
mdiobus_scan directly, and PXA does it on a known address. I do see tha=
t there
are trees that use macb and don't have a phy listed, which is unfortuna=
te.

Another way to fix our issue would be to consider all 0x0s a bad ID in
mdiobus_scan, so grounded MDIO lines do not get PHYs scanned.  Or we co=
uld add a
DT property to disable the manual scan.  I'm not sure what the correct =
solution
is, do you have a preference?
