From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 05:38:15 -0500
Message-ID: <1265020695.7499.151.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-02-01 at 12:25 +0200, Alexey Dobriyan wrote:
> On Mon, Feb 1, 2010 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 01 f=C3=A9vrier 2010 =C3=A0 11:36 +0200, Alexey Dobriyan a=
 =C3=A9crit :
> >> On Mon, Feb 1, 2010 at 11:32 AM, Jon Masters <jonathan@jonmasters.=
org> wrote:
> >> > I hacked up a per-namespace version of hashtables (this needs do=
ing
> >> > anyway, since the global stuff is just waiting to break)
> >>
> >> Which ones? Conntrack hashtables are per-netns.
> >
> > It seems they are, but this is not a complete work :

That's my point.

> They are per-netns.
>=20
> It's not "complete", because right now there is no point in doing mor=
e.
> nf_conntrack_max was rejected given the absense of per-netns kernel
> memory consumption limiting.
>=20
> > 1) Global settings (shared by all netns)
>=20
> Only hashtable size which is module parameter and
> there is no generic way to limit kernel memory (like beancounters).

And can be changed at any time you like (also an exported symbol) such
that existing hashtable indexing will fail and corrupt memory. There is
clearly a need for each of these hashtables to have its own metadata.

Jon.
