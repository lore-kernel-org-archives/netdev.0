From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Wed, 01 Dec 2010 18:31:57 +0100
Message-ID: <1291224717.2856.1021.camel@edumazet-laptop>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
	 <1291219386.2856.924.camel@edumazet-laptop>
	 <20101201171801.GA22009@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101201171801.GA22009@canuck.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 12:18 -0500, Thomas Graf a =C3=
=A9crit :
> On Wed, Dec 01, 2010 at 05:03:06PM +0100, Eric Dumazet wrote:
> > [PATCH net-next-2.6] net: kill an RCU warning in inet_fill_link_af(=
)
> >=20
> > commits 9f0f7272 (ipv4: AF_INET link address family) and cf7afbfeb8=
c
> > (rtnl: make link af-specific updates atomic) used incorrect
> > __in_dev_get_rcu() in RTNL protected contexts, triggering PROVE_RCU
> > warnings.
> >=20
> > Switch to __in_dev_get_rtnl(), wich is more appropriate, since we h=
old
> > RTNL.
> >=20
> > Based on a report and initial patch from Amerigo Wang.
>=20
> RTNL is not held while dumping, it is only held for get and set, but =
we
> still hold rcu readlocks while dumping so there should be no asserts
> triggered. Thanks for fixing this.

Are you sure RTNL is not held while dumping ?=20

Patrick did the change to hold RTNL while dumping too, 3.5 years ago.
Check commits 6313c1e0992fea, 1c2d670f3660e9103 ([RTNETLINK]: Hold
rtnl_mutex during netlink dump callbacks)

If this was the case (not holding RTNL), we should use
rcu_dereference(), not rtnl_dereference()
