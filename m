From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 11:12:40 +0100
Message-ID: <1265019160.2848.14.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 11:36 +0200, Alexey Dobriyan a =C3=
=A9crit :
> On Mon, Feb 1, 2010 at 11:32 AM, Jon Masters <jonathan@jonmasters.org=
> wrote:
> > I hacked up a per-namespace version of hashtables (this needs doing
> > anyway, since the global stuff is just waiting to break)
>=20
> Which ones? Conntrack hashtables are per-netns.

It seems they are, but this is not a complete work :

1) Global settings (shared by all netns)
2) nf_conntrack_cachep is shared, it should be not shared.
3) nf_conntrack_untracked shared by all netns, it should be local.

nf_conntrack_cleanup_net() can block forever because of this.

while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
	schedule();

=2E..


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
