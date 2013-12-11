From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH RFC] net: of_mdio: Scan PHYs which have device_type set to ethernet-phy
Date: Wed, 11 Dec 2013 09:15:44 +0000
Message-ID: <20131211091544.EA4F7C4061A@trevor.secretlab.ca>
References: <1384441556-20674-1-git-send-email-srinivas.kandagatla@st.com> < 1695129.4QIGmmVPkX@lenovo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree@vger.kernel.org, Rob Herring <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1695129.4QIGmmVPkX@lenovo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Dec 2013 07:15:54 +0000, Florian Fainelli <f.fainelli@gmail.=
com> wrote:
> Le jeudi 14 novembre 2013, 15:05:56 Srinivas Kandagatla a =C3=A9crit =
:
> > According to Documentation/devicetree/bindings/net/phy.txt device_t=
ype
> > property of PHY nodes is mandatory, which should be set to
> > "ethernet-phy". This patch adds check in scanning phys and only sca=
ns
> > node which have device-type set to "ethernet-phy".
>=20
> Please CC netdev@vger.kernel.org as there might be networking folks n=
ot=20
> actively following devicetree-discuss.
>=20
> >=20
> > Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> > ---
> >  drivers/of/of_mdio.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> > index d5a57a9..78c53c7 100644
> > --- a/drivers/of/of_mdio.c
> > +++ b/drivers/of/of_mdio.c
> > @@ -57,6 +57,9 @@ int of_mdiobus_register(struct mii_bus *mdio, str=
uct
> > device_node *np)
> >=20
> >  	/* Loop over the child nodes and register a phy_device for each o=
ne */
> >  	for_each_available_child_of_node(np, child) {
> > +		/* A PHY must have device_type set to "ethernet-phy" */
> > +		if (of_node_cmp(child->type, "ethernet-phy"))
> > +			continue;
>=20
> As already stated by Grant this will break quite a lot of platforms o=
ut there.=20
> Technically speaking, ePAPR v1.1 only specifies that "cpu" and "memor=
y" nodes=20
> should have a "device_type" property for compatibility. Altough I do =
agree=20
> that it is nice to have a properly set "device_type", we can't always=
 rely on=20
> that.=20

Actually it is the opposite. device_type is deprecated and has been for
a long time now. Device bindings should not not be using device_type
unless it is there for legacy compatibility.

g.
