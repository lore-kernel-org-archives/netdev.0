From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 3/5] net: dsa: complete dsa_switch_destroy
Date: Tue, 6 Oct 2015 08:23:28 +0100
Message-ID: <561376F0.4080806@baylibre.com>
References: <560FE57C.5070608@baylibre.com> <561039AF.8080706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561039AF.8080706@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/2015 09:25 PM, Florian Fainelli wrote:
> Le 03/10/2015 07:26, Neil Armstrong a =C3=A9crit :
>> When unbinding dsa, complete the dsa_switch_destroy to unregister th=
e
>> fixed link phy then cleanly unregister and destroy the net devices.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>=20
> [snip]
>=20
>> +		port_dn =3D cd->port_dn[port];
>> +		if (of_phy_is_fixed_link(port_dn)) {
>> +			phydev =3D of_phy_find_device(port_dn);
>> +			if (phydev) {
>> +				int addr =3D phydev->addr;
>> +				phy_device_free(phydev);
>> +				of_node_put(port_dn);
>> +				fixed_phy_del(addr);
>=20
> fixed_phy_del() removes the fixed PHY from the platform fixed MDIO bu=
s
> list of PHYs, so we should be okay even with switch drivers which
> register a link_update callback via fixed_phy_set_link_update(), but =
I
> have not checked that. The sequence of call looks (phy_device_free th=
en
> fixed_phy_del) looks sane though.
Actually I copied the exact sequence from the fixed link module, eventu=
ally this should be done in this module with a proper fixed_link_remove=
 function.

>=20
> Eventually this logic might be better moved into net/dsa/slave.c such
> that it is easy to see how it balances dsa_slave_phy_setup().
>=20
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>=20

Thanks for the review,

Neil
