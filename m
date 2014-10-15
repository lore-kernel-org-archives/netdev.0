From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Wed, 15 Oct 2014 15:45:27 -0700
Message-ID: <1413413127.17186.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
	 <20141015215701.GA4109@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?ISO-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141015215701.GA4109@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-15 at 14:57 -0700, Benjamin Poirier wrote:
> On 2014/10/13 12:52, Llu=C3=ADs Batlle i Rossell wrote:
> > Hello,
> >=20
> > on the 7th of January 2014 ths patch was applied:
> > https://lkml.org/lkml/2014/1/7/307
> >=20
> > [PATCH v2] net: Do not enable tx-nocache-copy by default
> >        =20
> > In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made pac=
kets to be
> > sent corrupted. I think this machine has something special about th=
e cache.
> >=20
> > Enabling back this tx-nocache-copy (as it used to be before the pat=
ch) the
> > transfers work fine again. I think that most people, encountering t=
his problem,
> > completely disable the tx offload instead of enabling back this set=
ting.
> >=20
> > Is this an ARM kernel problem regarding this platform?
>=20
> This is odd, only x86 defines ARCH_HAS_NOCACHE_UACCESS. On arm,
> skb_do_copy_data_nocache() should end up using __copy_from_user()
> regardless of tx-nocache-copy.

 kmap_atomic()/kunmap_atomic() is missing, so we lack
__cpuc_flush_dcache_area() operations.
