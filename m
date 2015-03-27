From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 16:52:57 +0300
Message-ID: <551560B9.1030505@list.ru>
References: <55155AFC.4050800@list.ru> <20150327133907.GA11975@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150327133907.GA11975@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.03.2015 16:39, Andrew Lunn =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, Mar 27, 2015 at 04:28:28PM +0300, Stas Sergeev wrote:
>> Hello.
>>
>> Currently the fixed-link DT binding is pre-configured and
>> cannot be changed in run-time. This means the cable unplug
>> events are not being detected, and the link parameters can't
>> be negotiated.
>=20
> O.K, i will ask the dumb question....
>=20
> Isn't fixed-link supposed to be used for links which are fixed?
> Why would a fixed-link change?
Hi, my current understanding of fixed-link DT binding is that
it is actually just an MDIO-less link, but not more fixed than that.
I made a patch out of that assumption.
Why I think that way is because fixed-link internally uses a fixed_phy
driver - the one that actually allows a state updates and emulates MDIO
on top of these. So I just exploited that already coded capability.
I think any other approach will require much more work.

> The use cases i've seen for this is when you are connecting the MAC t=
o
> a Switch. The link is configured to its fastest mode and then left
> alone.
>=20
> Please could you give some more background information. What do you
> have on the other end of this fixed link which keeps changing?
> Obviously not a switch.
Normal PHY, not a switch.
But there is no MDIO, because SGMII AFAIK doesn't need MDIO.
SGMII has in-band status, but for some reason it seems currently
linux is not ready for such setup - this is what my patch addresses.
Or maybe I am missing something?
