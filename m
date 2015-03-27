From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Fri, 27 Mar 2015 10:15:54 -0700
Message-ID: <5515904A.1060600@gmail.com>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com> <551587D1.5070408@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551587D1.5070408@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/03/15 09:39, Stas Sergeev wrote:
> 27.03.2015 19:21, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Do you want mvneta to register a similar callback in of_mdio, inste=
ad
>>> of adding an explicit state-updating functions? Something like
>>> of_phy_fixed_link_set_update_callback()?
>> You don't need an of_phy_fixed_link_set_update callback, you just ne=
ed
>> to provide a fixed_link_update callback in mvneta, that you register=
,
> That approach I in fact considered initially, as the simplest one,
> and even had a patch. But I disliked the fact that then mvneta will
> exploit the knowledge of the fact that of_phy_register_fixed_link()
> uses a fixed_phy driver. What if the implementation will later change=
?

There is no reason why it should change later, that's the entire purpos=
e
of why we can tell whether it is a fixed PHY or a regular MDIO-managed
PHY, and drivers rely on that for their operations.

> Also what makes me uncomfortable is that since of_phy_register_fixed_=
link()
> doesn't even return the struct phy_device pointer, mvneta will have
> to get around that and use for example of_phy_find_device(), or regis=
ter
> the callback later, after of_phy_connect()

Ok, you could either make of_phy_register_fixed_link() return a
phy_device, or as you suggest resolve the phy_device from the
device_node later, your call.

=2E dsa/slave.c does of_phy_connect()
> initially, together with fixed link registration, so it gets around t=
he
> problem. But mvneta registers the fixed_link in .probe callback, and
> does of_phy_connect() in .open callback.
> This all made me to drop that idea despite the simplicity.

Yet that's still the cleanest/less invasive approach imho.

>=20
>>> This will remove a few changes indeed, but perhaps not too much.
>>> Please confirm if this is exactly what you want, and then I try.
>> Let me know if this is clearer now, if not, I can certainly cook a
>> patch which does what I am suggesting. Thanks!
> I can do that too, because I already did.
> Let me know if the above concerns are not important, and I'll
> restore my initial patch.
>=20

I think your concerns are valid, but I don't think there is going to be
any problem with the approach I suggested because there is a contract
that the fixed PHYs and regular PHYs need to
--=20
=46lorian
