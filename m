From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xtables: stackptr should be percpu
Date: Mon, 31 May 2010 15:44:08 +0200
Message-ID: <1275313448.3291.49.camel@edumazet-laptop>
References: <1275303998-2435-1-git-send-email-dfeng@redhat.com>
	 <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr>
	 <1275311580.3291.44.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1005311519340.25402@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiaotian Feng <dfeng@redhat.com>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005311519340.25402@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 31 mai 2010 =C3=A0 15:22 +0200, Jan Engelhardt a =C3=A9crit :
> On Monday 2010-05-31 15:13, Eric Dumazet wrote:
> >
> >All cpus share a single cache line for their 'stackptr' storage,
> >introduced in commit f3c5c1bfd4
> >
> >This is a stable candidate (2.6.34)
>=20
> Stackptr was first introduced for 2.6.35-rcX.
>=20

Indeed, I was fooled by 'git describe'

> >+	i->stackptr =3D alloc_percpu(unsigned int);
> > 	if (i->stackptr =3D=3D NULL)
> > 		return -ENOMEM;
> >-	memset(i->stackptr, 0, size);
> >=20
> > 	size =3D sizeof(void **) * nr_cpu_ids;
> > 	if (size > PAGE_SIZE)
>=20
> Are alloc_percpu areas cleared?
>=20

Yes, allocated chunks are cleared.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
