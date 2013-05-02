From: Dan Williams <dcbw@redhat.com>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 13:15:32 -0500
Message-ID: <1367518532.7757.14.camel@dcbw.foobar.com>
References: <20130502.133947.387694205526879673.davem@davemloft.net>
	 <CAHXqBF+Xb0ZVo2tO-0m59JJDrwy5vYX6=jLbts_ZAv5Pk+7SCw@mail.gmail.com>
	 <20130502.135542.1332946768988319212.davem@davemloft.net>
	 <20130502.140648.1138582574178897490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130502.140648.1138582574178897490.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-02 at 14:06 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 02 May 2013 13:55:42 -0400 (EDT)
>=20
> > From: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
> > Date: Thu, 2 May 2013 19:47:25 +0200
> >=20
> >> Are you sure it's "flags"? /sys/class/net/*/features were removed =
some
> >> time ago, and flags don't depend on NETIF_F_*.
> >=20
> > Oh, it's flags, which is printed in raw hex by net/core/net-sysfs.c=
:
> >=20
> > NETDEVICE_SHOW(flags, fmt_hex);
>=20
> Oh you're right, I'm confusing netdev->flags with netdev->features, m=
y bad.

Was just going to ask about that.  NM only cares about 'flags', not
features, at this point in time.  Relevant code for carrier notificatio=
n
in NM, using libnl helpers:

	link_obj =3D (struct rtnl_link *) obj;
	flags =3D rtnl_link_get_flags (link_obj);
	ifidx =3D rtnl_link_get_ifindex (link_obj);

	nm_log_dbg (LOGD_HW, "netlink link message: iface idx %d flags 0x%X",
ifidx, flags);

	if (flags & IFF_LOWER_UP)
		g_signal_emit (self, signals[CARRIER_ON], 0, ifidx);
	else
		g_signal_emit (self, signals[CARRIER_OFF], 0, ifidx);

So it's got to be something else other than the netdev features orderin=
g
that's screwing up for Linus.  I'm sure we'd have heard about it a long=
,
long time ago if something had messed up dev->flags bits...

Dan
