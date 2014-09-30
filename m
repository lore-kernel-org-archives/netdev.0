From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the
 core
Date: Tue, 30 Sep 2014 10:56:22 +0200
Message-ID: <20140930085622.GA3916@salvia>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
 <1411994363-8451-33-git-send-email-pablo@netfilter.org>
 <1412028266.30721.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140929231748.GA11709@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140929231748.GA11709@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 01:17:48AM +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2014-09-29 at 14:39 +0200, Pablo Neira Ayuso wrote:
> > > Jesper reported that br_netfilter always registers the hooks sinc=
e
> > > this is part of the bridge core. This harms performance for peopl=
e that
> > > don't need this.
> > >=20
> > > This patch modularizes br_netfilter so it can be rmmod'ed, thus,
> > > the hooks can be unregistered. I think the bridge netfilter shoul=
d have
> > > been a separated module since the beginning, Patrick agreed on th=
at.
> > >=20
> > > Note that this is breaking compatibility for users that expect th=
at
> > > bridge netfilter is going to be available after explicitly 'modpr=
obe
> > > bridge' or via automatic load through brctl.
> > >=20
> > > However, the damage can be easily undone by modprobing br_netfilt=
er.
> > > The bridge core also spots a message to provide a clue to people =
that
> > > didn't notice that this has been deprecated.
> > >=20
> > > On top of that, the plan is that nftables will not rely on this s=
oftware
> > > layer, but integrate the connection tracking into the bridge laye=
r to
> > > enable stateful filtering and NAT, which is was bridge netfilter =
users
> > > seem to require.
> > >=20
> > > This patch still keeps the fake_dst_ops in the bridge core, since=
 this
> > > is required by when the bridge port is initialized. So we can saf=
ely
> > > modprobe/rmmod br_netfilter anytime.
> > >=20
> > > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > > Acked-by: Florian Westphal <fw@strlen.de>
> > > ---
> >=20
> > Hmm... What am I missing here ?
> > # CONFIG_BRIDGE_NETFILTER is not set
>=20
> Nothing.  Our fault.  br_nf_core.o should not be built in this case.
>=20
> > $ make net/bridge/br_nf_core.o
> [..]
> >   CC [M]  net/bridge/br_nf_core.o
> > net/bridge/br_nf_core.c:77:1: error: expected identifier or =E2=80=98=
(=E2=80=99 before =E2=80=98{=E2=80=99 token
> > net/bridge/br_nf_core.c:88:12: error: redefinition of =E2=80=98br_n=
f_core_init=E2=80=99
>=20
> This patch seems to fix it for me.  Pablo, can you double-check?

Thanks Florian, I'll pass this patch to David asap.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
