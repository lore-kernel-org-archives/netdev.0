From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Tue, 22 Nov 2011 17:32:59 +0100
Message-ID: <1321979579.18002.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111121161036.GA1679@x4.trippels.de>
	   <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <20111121173556.GA1673@x4.trippels.de>
	   <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	   <20111121195113.GA1678@x4.trippels.de>
	 <1321907275.13860.12.camel@pasglop>
	   <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	   <alpine.DEB.2.00.1111212105330.19606@router.home>
	   <20111122084513.GA1688@x4.trippels.de>
	 <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1321955185.2474.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <alpine.DEB.2.00.1111220844400.25785@router.home>
	 <1321973567.2474.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1111220900330.25785@router.home>
	 <alpine.DEB.2.00.1111220907050.25785@router.home>
	 <alpine.DEB.2.00.1111221014030.28197@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau
 <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
  "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>,  "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.00.1111221014030.28197@router.home>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 22 novembre 2011 =C3=A0 10:20 -0600, Christoph Lameter a =C3=A9c=
rit :
> Argh. The Redzoning (and the general object pad initialization) is outs=
ide
> of the slab_lock now. So I get wrong positives on those now. That
> is already in 3.1 as far as I know. To solve that we would have to cove=
r a
> much wider area in the alloc and free with the slab lock.
>=20
> But I do not get the count mismatches that you saw. Maybe related to
> preemption. Will try that next.

Also I note the checks (redzoning and all features) that should be done
in kfree() are only done on slow path ???
f
...
stat(s, FREE_SLOWPATH);

if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
...

This is unfortunate...


I am considering adding a "quarantine" capability : each cpu will
maintain in its struct kmem_cache_cpu a FIFO list of "s->quarantine_max"
freed objects.

So it should be easier to track use after free bugs, setting
quarantine_max to a big value.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
