From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a
 separate module
Date: Mon, 25 Oct 2010 12:14:00 +0200
Message-ID: <1288001640.2826.96.camel@edumazet-laptop>
References: <20101021104709.5192.31249.stgit@este.odu>
	 <20101021104709.5192.64336.stgit@este.odu>  <4CC02456.4050301@trash.net>
	 <1287661385.13326.45.camel@este.odu>  <4CC0486D.60703@trash.net>
	 <1287699558.2607.5.camel@edumazet-laptop>
	 <1287999512.2160.25.camel@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287999512.2160.25.camel@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 25 octobre 2010 =C3=A0 11:38 +0200, KOVACS Krisztian a =C3=A9c=
rit :
> Hi,
>=20
> On Fri, 2010-10-22 at 00:19 +0200, Eric Dumazet wrote:
> > Le jeudi 21 octobre 2010 =C3=A0 16:04 +0200, Patrick McHardy a =C3=A9=
crit :
> > > Am 21.10.2010 13:43, schrieb KOVACS Krisztian:
> > > > tproxy: split off ipv6 defragmentation to a separate module
> > > >    =20
> > > >     Like with IPv4, TProxy needs IPv6 defragmentation but does =
not
> > > >     require connection tracking. Since defragmentation was coup=
led
> > > >     with conntrack, I split off the two, creating an nf_defrag_=
ipv6 module,
> > > >     similar to the already existing nf_defrag_ipv4.
> > >=20
> > > Applied, thanks.
> >=20
> > Hmm...
> >=20
> > CONFIG_IPV6=3Dm
> > CONFIG_NETFILTER_TPROXY=3Dm
> >=20
> >=20
> >   MODPOST 201 modules
> > ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_TPROXY.ko] undefin=
ed!
> > ERROR: "ipv6_find_hdr" [net/netfilter/xt_TPROXY.ko] undefined!
> >=20
> > Sorry, it's late here, I wont fix this ;)
>=20
> Oops, I guess this is because you do have IPv6 support but don't have
> ip6tables enabled in your config. Does the patch below fix the issue =
for
> you? (For me it now compiles with and without IPv6 conntrack, ip6tabl=
es
> and IPv6 support, too.)
>=20
>=20

I had ip6tables enabled, but not CONFIG_NF_CONNTRACK_IPV6 ;)

>=20
> netfilter: fix module dependency issues with IPv6 defragmentation, ip=
6tables and xt_TPROXY
>=20
> One of the previous tproxy related patches split IPv6 defragmentation=
 and
> connection tracking, but did not correctly add Kconfig stanzas to han=
dle the
> new dependencies correctly. This patch fixes that by making the confi=
g options
> mirror the setup we have for IPv4: a distinct config option for defra=
gmentation
> that is automatically selected by both connection tracking and
> xt_TPROXY/xt_socket.
>=20
> The patch also changes the #ifdefs enclosing IPv6 specific code in xt=
_socket
> and xt_TPROXY: we only compile these in case we have ip6tables suppor=
t enabled.
>=20
> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
