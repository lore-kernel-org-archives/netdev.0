From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Thu, 12 Feb 2009 18:03:32 +0200
Message-ID: <1234454612.28812.181.camel@penberg-laptop>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang> <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
	 <1232703989.6094.29.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231020030.21692@qirst.com>
	 <1232765728.11429.193.camel@ymzhang>
	 <84144f020901232336v71687223y2fb21ee081c7517f@mail.gmail.com>
	 <1234416153.2604.387.camel@ymzhang>  <1234417660.2604.391.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, Ingo Molnar <mingo@elte.hu>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752010AbZBLQDv@vger.kernel.org>
In-Reply-To: <1234417660.2604.391.camel@ymzhang>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-01-24 at 09:36 +0200, Pekka Enberg wrote:
> > > On Fri, 2009-01-23 at 10:22 -0500, Christoph Lameter wrote:
> > > >> No there is another way. Increase the allocator order to 3 for=
 the
> > > >> kmalloc-8192 slab then multiple 8k blocks can be allocated fro=
m one of the
> > > >> larger chunks of data gotten from the page allocator. That wil=
l allow slub
> > > >> to do fast allocs.
> > >=20
> > > On Sat, Jan 24, 2009 at 4:55 AM, Zhang, Yanmin
> > > <yanmin_zhang@linux.intel.com> wrote:
> > > > After I change kmalloc-8192/order to 3, the result(pinned netpe=
rf UDP-U-4k)
> > > > difference between SLUB and SLQB becomes 1% which can be consid=
ered as fluctuation.
> > >=20
> > > Great. We should fix calculate_order() to be order 3 for kmalloc-=
8192.
> > > Are you interested in doing that?

On Thu, 2009-02-12 at 13:22 +0800, Zhang, Yanmin wrote:
> > Pekka,
> >=20
> > Sorry for the late update.
> > The default order of =EF=BB=BFkmalloc-8192 on 2*4 stoakley is reall=
y an issue of calculate_order.

On Thu, 2009-02-12 at 13:47 +0800, Zhang, Yanmin wrote:
> Oh, previous patch has a compiling warning. Pls. use below patch.
>=20
> From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
>=20
> =EF=BB=BFThe default order of =EF=BB=BFkmalloc-8192 on 2*4 stoakley i=
s an issue of calculate_order.

Applied to the 'topic/slub/perf' branch. Thanks!

			Pekka
