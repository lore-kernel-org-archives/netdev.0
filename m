From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: Re: [PATCH v2 net-next] sky2: use random address if EEPROM is bad
Date: Wed, 12 Aug 2015 10:15:13 +0100
Message-ID: <20150812091513.GU20890@e106497-lin.cambridge.arm.com>
References: <55C2AB51.1040409@gmail.com>
 <1439303756-30333-1-git-send-email-Liviu.Dudau@arm.com>
 <55CA4546.40904@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mirko Lindner <mlindner@marvell.com>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CA4546.40904@cogentembedded.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 11, 2015 at 07:56:06PM +0100, Sergei Shtylyov wrote:
> Hello.
>=20
> On 08/11/2015 05:35 PM, Liviu Dudau wrote:
>=20
> > On some embedded systems the EEPROM does not contain a valid MAC ad=
dress.
> > In that case it is better to fallback to a generated mac address an=
d
> > let init scripts fix the value later.
>=20
> > Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > [Changed handcoded setup to use eth_hw_addr_random() instead]
> > Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
> > ---
> > I have tested this on my Juno platform and I can successfully do an=
 nfsroot boot.
>=20
> > Best regards,
> > Liviu
>=20
> >   drivers/net/ethernet/marvell/sky2.c | 7 +++++++
> >   1 file changed, 7 insertions(+)
>=20
> > diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethe=
rnet/marvell/sky2.c
> > index d9f4498..c309879 100644
> > --- a/drivers/net/ethernet/marvell/sky2.c
> > +++ b/drivers/net/ethernet/marvell/sky2.c
> > @@ -4819,6 +4819,13 @@ static struct net_device *sky2_init_netdev(s=
truct sky2_hw *hw, unsigned port,
> >   		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
> >   			      ETH_ALEN);
> >
> > +	/* if the address is invalid, use a random value */
> > +	if (!is_valid_ether_addr(dev->dev_addr)) {
> > +		netdev_warn(dev,
> > +			"Invalid MAC address, defaulting to random\n");
>=20
>     Please start the continuation line right under 'dev' on the borke=
n up line.

OK, I will make the changes for v3.

>=20
> > +		eth_hw_addr_random(dev);
> > +	}
> > +
> >   	return dev;
> >   }
>=20
> MBR, Sergei
>=20

Thanks for reviewing this!

Best regards,
Liviu

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    =C2=AF\_(=E3=83=84)_/=C2=AF
