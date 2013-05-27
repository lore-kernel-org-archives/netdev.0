From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: phy: prevent linking breakage
Date: Tue, 28 May 2013 00:20:05 +0200
Message-ID: <201305272320.08296.f.fainelli@gmail.com>
References: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
	<1369671524-14797-2-git-send-email-alexandre.belloni@free-electrons.com>
	<20130527163913.GO32299@pengutronix.de>
	<51A399D6.8030000@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Shawn Guo <shawn.guo@linaro.org>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <kernel@pengutronix.de>,
	linux-kernel@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A399D6.8030000@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le 27 mai 2013 19:38, "Alexandre Belloni" <alexandre.belloni@free-
electrons.com> a =C3=A9crit :

[snip]

> >> +/*
> >> + *  phy_register_fixup{,_for_uid,_for_id} are called from arch/ s=
o this=20
won't
> >> + *  work unless phylib is compiled in the kernel.
> >> + *  Defining stubs allows to prevent linking errors.
> >> + */
> >> +#ifdef CONFIG_PHYLIB
> >>  int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_u=
id_mask,
> >>              int (*run)(struct phy_device *));
> >>  int phy_register_fixup_for_id(const char *bus_id,
> >>              int (*run)(struct phy_device *));
> >>  int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
> >>              int (*run)(struct phy_device *));
> >> +#else
> >> +#define phy_register_fixup(a, b, c, d) do { } while (0)
> >> +#define phy_register_fixup_for_id(a, b) do { } while (0)
> >> +#define phy_register_fixup_for_uid(a, b, c) do { } while (0)
> > Use static inline functions here. This breaks if someone does resul=
t
> > checking on the functions which then expands to ret =3D do {} while=
 (0);
> > Also we still have
> Right, I tried that first but forgot static so I had issues with
> redefinition of the functions. I even played with __weak at some poin=
t...

You might even want to make these static inlines as mentionned earlier,=
 and=20
return something like -ENOTSUPP so that someone using these in board co=
de and=20
wondering why they do not work gets a chance to enable CONIFG_PHYLIB.
--
=46lorian
