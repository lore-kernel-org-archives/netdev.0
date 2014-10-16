From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Thu, 16 Oct 2014 19:46:28 +0200
Message-ID: <20141016174628.GL1972@vicerveza.homeunix.net>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
 <20141015215701.GA4109@f1.synalogic.ca>
 <1413413127.17186.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141016173401.GA16515@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141016173401.GA16515@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2014 at 10:34:01AM -0700, Benjamin Poirier wrote:
> On 2014/10/15 15:45, Eric Dumazet wrote:
> > On Wed, 2014-10-15 at 14:57 -0700, Benjamin Poirier wrote:
> > > On 2014/10/13 12:52, Llu=EDs Batlle i Rossell wrote:
> > > > Hello,
> > > >=20
> > > > on the 7th of January 2014 ths patch was applied:
> > > > https://lkml.org/lkml/2014/1/7/307
> > > >=20
> > > > [PATCH v2] net: Do not enable tx-nocache-copy by default
> > > >        =20
> > > > In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made=
 packets to be
> > > > sent corrupted. I think this machine has something special abou=
t the cache.
> > > >=20
> > > > Enabling back this tx-nocache-copy (as it used to be before the=
 patch) the
> > > > transfers work fine again. I think that most people, encounteri=
ng this problem,
> > > > completely disable the tx offload instead of enabling back this=
 setting.
> > > >=20
> > > > Is this an ARM kernel problem regarding this platform?
> > >=20
> > > This is odd, only x86 defines ARCH_HAS_NOCACHE_UACCESS. On arm,
> > > skb_do_copy_data_nocache() should end up using __copy_from_user()
> > > regardless of tx-nocache-copy.
> >=20
> >  kmap_atomic()/kunmap_atomic() is missing, so we lack
> > __cpuc_flush_dcache_area() operations.
> >=20
>=20
> You lost me there.
> 1) I don't see the link
> 2) It seems kmap_atomic and so on are there:
> $ grep kmap_atomic System.map-3.16-2-kirkwood
> c0014838 T kmap_atomic
> c001491c T kmap_atomic_pfn
> c00149a4 T kmap_atomic_to_page
>=20
> MACH_KIRKWOOD selects CPU_FEROCEON which has
> __cpuc_flush_dcache_area ->
> 	cpu_cache.flush_kern_dcache_area ->
> 		feroceon_flush_kern_dcache_area

Hello all,

it seems I was a bit wrong - although enabling back tx-nocache-copy mak=
es the
tx-errors happen much less often (ssh complaining about HMAC), they sti=
ll
happen. It seems that something was introduced in some recent kernels t=
hat broke
the tx offload.

I have no idea what it can be, but since 2.6 until at least 3.10 the ne=
twork
driver worked fine with tx offload in this sheevaplug board.

Regards,
Llu=EDs.
