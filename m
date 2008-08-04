From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 4/4] Configure out IGMP support
Date: Mon, 4 Aug 2008 14:48:07 +0200
Message-ID: <20080804144807.6b2374d9@surf>
References: <20080731092703.661994657@free-electrons.com>
	<20080731093221.565015353@free-electrons.com>
	<1217619715.3454.488.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <1217619715.3454.488.camel@pmac.infradead.org>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Fri, 01 Aug 2008 20:41:55 +0100,
David Woodhouse <dwmw2@infradead.org> a =C3=A9crit :

> The config option probably lives in net/Kconfig, not init/Kconfig.

Yes, it could. But AFAIK, until now, all CONFIG_EMBEDDED-related
options have been put in init/Kconfig. But if it's preferred, I can of
course change the patch to move the config option to net/Kconfig.

> And please could you make it clear how this interacts with
> IP_MULTICAST?
>=20
> We already have a CONFIG_IP_MULTICAST option, for which the help text
> says "For more people, it's safe to say N'. And I think it defaults t=
o
> that too. What more does CONFIG_IGMP remove? It's not made clear by
> the help text.

The interaction of IGMP support with CONFIG_IP_MULTICAST is fairly
unclear to me.

A large portion of igmp.c is already under #ifdef CONFIG_IP_MULTICAST:
all the igmp_*() functions, amongst which is igmp_rcv(), referenced in
igmp_protocol in net/ipv4/af_inet.c, which is compiled-out
when !CONFIG_IP_MULTICAST.

All the proc-related code at the end of the file is only conditionnaly
compiled on CONFIG_PROC_FS, but seems to in fact be only used if both
CONFIG_IP_MULTICAST and CONFIG_PROC_FS are selected:
igmp_mc_proc_init() in net/ipv4/ip_output.c is only called when
CONFIG_IP_MULTICAST and CONFIG_PROC_FS are selected.

Besides that, it's unclear to me why the ip_mc_*() functions are useful
when !CONFIG_IP_MULTICAST, but I'm probably missing something. They are
used to implement setsockopt-operations related to multicast, hooks for
the routing code to handle multicast-related traffic, etc.

Sincerly,

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
