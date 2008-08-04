From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 4/4] Configure out IGMP support
Date: Mon, 04 Aug 2008 14:53:16 +0100
Message-ID: <1217857996.3454.622.camel@pmac.infradead.org>
References: <20080731092703.661994657@free-electrons.com>
	 <20080731093221.565015353@free-electrons.com>
	 <1217619715.3454.488.camel@pmac.infradead.org>
	 <20080804144807.6b2374d9@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20080804144807.6b2374d9@surf>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-08-04 at 14:48 +0200, Thomas Petazzoni wrote:
> Le Fri, 01 Aug 2008 20:41:55 +0100,
> David Woodhouse <dwmw2@infradead.org> a =C3=A9crit :
>=20
> > The config option probably lives in net/Kconfig, not init/Kconfig.
>=20
> Yes, it could. But AFAIK, until now, all CONFIG_EMBEDDED-related
> options have been put in init/Kconfig. But if it's preferred, I can o=
f
> course change the patch to move the config option to net/Kconfig.

It clearly lives in net/Kconfig.

> > And please could you make it clear how this interacts with
> > IP_MULTICAST?
> >=20
> > We already have a CONFIG_IP_MULTICAST option, for which the help te=
xt
> > says "For more people, it's safe to say N'. And I think it defaults=
 to
> > that too. What more does CONFIG_IGMP remove? It's not made clear by
> > the help text.
>=20
> The interaction of IGMP support with CONFIG_IP_MULTICAST is fairly
> unclear to me.
>=20
> A large portion of igmp.c is already under #ifdef CONFIG_IP_MULTICAST=
:
> all the igmp_*() functions, amongst which is igmp_rcv(), referenced i=
n
> igmp_protocol in net/ipv4/af_inet.c, which is compiled-out
> when !CONFIG_IP_MULTICAST.
>=20
> All the proc-related code at the end of the file is only conditionnal=
y
> compiled on CONFIG_PROC_FS, but seems to in fact be only used if both
> CONFIG_IP_MULTICAST and CONFIG_PROC_FS are selected:
> igmp_mc_proc_init() in net/ipv4/ip_output.c is only called when
> CONFIG_IP_MULTICAST and CONFIG_PROC_FS are selected.
>=20
> Besides that, it's unclear to me why the ip_mc_*() functions are usef=
ul
> when !CONFIG_IP_MULTICAST, but I'm probably missing something.=20

Most of them aren't, as far as I can tell.=20

> They are used to implement setsockopt-operations related to multicast=
,
> hooks for the routing code to handle multicast-related traffic, etc.

I wonder if those options should return errors now, rather than silentl=
y
failing but returning zero. Or maybe that _would_ cause a stock build o=
f
ntpd to fail? Not that it really matters if it _does_, though.

It sounds like 'CONFIG_IGMP' is a bad name for the option, too -- and
the help text is similarly misleading. I think you need to work out how
it all fits together with CONFIG_IP_MULTICAST, fix it up, and resubmit
it.

--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n
