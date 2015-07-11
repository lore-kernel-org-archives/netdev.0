From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 10 Jul 2015 17:15:35 -0700
Message-ID: <55A06027.1020701@gmail.com>
References: <559FF511.5080102@list.ru> <559FF5A3.2030607@list.ru> <55A02E90.1090602@gmail.com> <55A035A2.2040404@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A035A2.2040404@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/15 14:14, Stas Sergeev wrote:
> 10.07.2015 23:44, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 10/07/15 09:41, Stas Sergeev wrote:
>>> Currently fixed_phy driver recognizes only the link-up state.
>>> This simple patch adds an implementation of link-down state.
>>> The actual change is 1-line, the rest is an indentation.
>> It is not clear to me how this is useful, if you have a link_update
>> callback manipulating the link state, the fixed PHY driver returns
>> appropriate MII_BMSR values and always re-initializes everything.
> It returns the appropriate values only for link status (when its down=
),
> but it still returns speed, duplex etc as if the link is up. I had ha=
rd
> times finding the relevant specs, but from what I have googled,
> when link is down, the speed/duplex/etc status fields should _also_
> be zero, which is what my patch does.
> What is more important is that fixed_phy_add() would return
> -EINVAL if you didn't specify speed while the link is down.
> This is an absolute must-fix, or I will have to add an arbitrary
> speed value again, on which you already objected.

Ok, but that does not seems to be a code path that you can hit, unless
you are already modifying
drivers/of/of_mdio.c::of_fixed_phy_register_link() and overriding how
status.link is defined, am I missing something?

>=20
>> Is this meant to be some sort of optimization? If so, you could just
>> avoid the re-intendation completely and do a goto instead?
> Oh, c'mon... Adding goto just to keep the _patch_ smaller?

Well, yes, so it's easy to audit the changes?

> (not smaller code, just a smaller patch)
> Well, this is certainly something that can be done, feel free
> to request that explicitly and I'll release v3 next week.

I hereby explicitly request that you make this a new iteration using a =
goto.

Thank you.
--=20
=46lorian
