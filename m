From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Sat, 24 Jan 2009 10:55:28 +0800
Message-ID: <1232765728.11429.193.camel@ymzhang>
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
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
	 <1232703989.6094.29.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231020030.21692@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
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
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0901231020030.21692@qirst.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-23 at 10:22 -0500, Christoph Lameter wrote:
> On Fri, 23 Jan 2009, Pekka Enberg wrote:
> 
> > Looking at __slab_free(), unless page->inuse is constantly zero and we
> > discard the slab, it really is just cache effects (10% sounds like a
> > lot, though!). AFAICT, the only way to optimize that is with Christoph's
> > unfinished pointer freelists patches or with a remote free list like in
> > SLQB.
> 
> No there is another way. Increase the allocator order to 3 for the
> kmalloc-8192 slab then multiple 8k blocks can be allocated from one of the
> larger chunks of data gotten from the page allocator. That will allow slub
> to do fast allocs.
After I change kmalloc-8192/order to 3, the result(pinned netperf UDP-U-4k)
difference between SLUB and SLQB becomes 1% which can be considered as fluctuation.

But when trying to increased it to 4, I got:
[root@lkp-st02-x8664 slab]# echo "3">kmalloc-8192/order
[root@lkp-st02-x8664 slab]# echo "4">kmalloc-8192/order
-bash: echo: write error: Invalid argument

Comparing with SLQB, it seems SLUB needs too many investigation/manual finer-tuning
against specific benchmarks. One hard is to tune page order number. Although SLQB also
has many tuning options, I almost doesn't tune it manually, just run benchmark and
collect results to compare. Does that mean the scalability of SLQB is better?


