From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Mon, 01 Feb 2010 16:02:28 +0100
Message-ID: <1265036548.2848.55.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 16:58 +0200, Alexey Dobriyan a =C3=
=A9crit :
> On Mon, Feb 1, 2010 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > +       net->ct.nf_conntrack_cachep =3D kmem_cache_create("nf_connt=
rack",
> > +                                                       sizeof(stru=
ct nf_conn), 0,
> > +                                                       SLAB_DESTRO=
Y_BY_RCU, NULL);
>=20
> Duplicate slab name detected.
>=20

OK, need to build an unique name I guess... "nf_conntrack-%d", net->id

> Can we clarify this?
>=20
> Is checking for ct->ct_net enough to avoid the bug
> while maintaining per-netns/global status quo?

No, I am afraid its not possible without adding big overhead in
fastpath.
