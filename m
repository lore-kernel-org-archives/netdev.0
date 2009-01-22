From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Thu, 22 Jan 2009 17:28:37 +0800
Message-ID: <1232616517.11429.129.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:52737 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753534AbZAVJ2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:28:47 -0500
In-Reply-To: <1232615707.14549.6.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 11:15 +0200, Pekka Enberg wrote:
> On Thu, 2009-01-22 at 16:36 +0800, Zhang, Yanmin wrote:
> > On Wed, 2009-01-21 at 18:58 -0500, Christoph Lameter wrote:
> > > On Tue, 20 Jan 2009, Zhang, Yanmin wrote:
> > >=20
> > > > kmem_cache =EF=BB=BFskbuff_head_cache's object size is just 256=
, so it shares the kmem_cache
> > > > with =EF=BB=BF:0000256. Their order is 1 which means every slab=
 consists of 2 physical pages.
> > >=20
> > > That order can be changed. Try specifying slub_max_order=3D0 on t=
he kernel
> > > command line to force an order 0 alloc.
> > I tried =EF=BB=BFslub_max_order=3D0 and there is no improvement on =
this UDP-U-4k issue.
> > Both get_page_from_freelist and __free_pages_ok's cpu time are stil=
l very high.
> >=20
> > I checked my instrumentation in kernel and found it's caused by lar=
ge object allocation/free
> > whose size is more than PAGE_SIZE. Here its order is 1.
> >=20
> > The right free callchain is __kfree_skb =3D> skb_release_all =3D> s=
kb_release_data.
> >=20
> > So this case isn't the issue that batch of allocation/free might er=
ase partial page
> > functionality.
>=20
> So is this the kfree(skb->head) in skb_release_data() or the put_page=
()
> calls in the same function in a loop?
It's =EF=BB=BFkfree(skb->head).

>=20
> If it's the former, with big enough size passed to __alloc_skb(), the
> networking code might be taking a hit from the SLUB page allocator
> pass-through.


