From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 17:20:32 +0300
Message-ID: <55156730.5030807@list.ru>
References: <55155AFC.4050800@list.ru> <20150327133907.GA11975@lunn.ch> <551560B9.1030505@list.ru> <20150327135904.GB11975@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150327135904.GB11975@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.03.2015 16:59, Andrew Lunn =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> But there is no MDIO, because SGMII AFAIK doesn't need MDIO.
>> SGMII has in-band status, but for some reason it seems currently
>> linux is not ready for such setup - this is what my patch addresses.
>=20
> Hacking the fixed-link driver feels wrong to me. You probably want to
> implement an SGMII-link driver. With some refactoring you can probabl=
y
> re-use some of the fixed-link driver code, but it should be a separat=
e
> driver, with its own DT binding.
Well I took the path of "the least resistance" of course...
and the one that doesn't look unreasonable to me, but the separate
driver is an option too. Though it will really be just the "same
fixed-link with 3 added functions to change properties". Do we really
need 2 mostly similar drivers? Esp when one includes the functionality
of the other, and just adds a bit on top? Maybe having just one, with
all the capabilities added?
=46or example, maybe someone will later want the ability to alter the
properties of fixed-link with ethtool or alike? Will this also require
"just another fixed link driver"?
Having one fully-featured driver will allow us to add the "sgmii-link"
DT binding as an alias to "fixed-link" and some function like
of_phy_fixed_link_is_sgmii() that will tell us whether we need an
in-band status or not.

> But i'm no export here. So lets see what others say.
Right. If people will be negative to an addition to fixed-link driver,
I'll take a look into adding a new DT binding - something I'd really
like to avoid doing. :) More work, more code, and yet even a new config
option - this have to be justified.
