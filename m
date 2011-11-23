From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
Date: Wed, 23 Nov 2011 17:04:51 +0100
Message-ID: <1322064291.17693.54.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111121131531.GA1679@x4.trippels.de>
	 <20111121153621.GA1678@x4.trippels.de>
	 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	 <alpine.DEB.2.00.1111212105330.19606@router.home>
	 <1321948113.27077.24.camel@edumazet-laptop>
	 <1321999085.14573.2.camel@pasglop>
	 <alpine.DEB.2.01.1111221511070.8000@trent.utfs.org>
	 <1322007501.14573.15.camel@pasglop>
	 <alpine.DEB.2.01.1111222145470.8000@trent.utfs.org>
	 <CAOJsxLGWTRuwQ04Mg26fNhZEmo7yVXG5vSZgF7Q5GESCk65odA@mail.gmail.com>
	 <alpine.DEB.2.00.1111230907330.16139@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pekka Enberg <penberg@kernel.org>, Christian Kujau
 <lists@nerdbynature.de>,  Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Markus Trippelsdorf <markus@trippelsdorf.de>,
 "Alex,Shi" <alex.shi@intel.com>,  "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,  David Rientjes
 <rientjes@google.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.00.1111230907330.16139@router.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mercredi 23 novembre 2011 =C3=A0 09:14 -0600, Christoph Lameter a =C3=A9=
crit :

> I think he only tested the patch that he showed us. Here is the patch
> cleaned up. Do you Want me to feed you the debug fixes patch by patch a=
s
> well?
>=20
> Subject: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
>=20
> The cmpxchg must be irq safe. The fallback for this_cpu_cmpxchg only
> disables preemption which results in per cpu partial page operation
> potentially failing on non x86 platforms.
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>
>=20
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c	2011-11-23 09:10:48.000000000 -0600
> +++ linux-2.6/mm/slub.c	2011-11-23 09:10:57.000000000 -0600
> @@ -1969,7 +1969,7 @@ int put_cpu_partial(struct kmem_cache *s
>  		page->pobjects =3D pobjects;
>  		page->next =3D oldpage;
>=20
> -	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) !=3D o=
ldpage);
> +	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) !=3D=
 oldpage);
>  	stat(s, CPU_PARTIAL_FREE);
>  	return pobjects;
>  }

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
