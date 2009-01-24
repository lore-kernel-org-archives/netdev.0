From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Sat, 24 Jan 2009 09:36:50 +0200
Message-ID: <84144f020901232336v71687223y2fb21ee081c7517f@mail.gmail.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang> <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
	 <1232703989.6094.29.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231020030.21692@qirst.com>
	 <1232765728.11429.193.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232765728.11429.193.camel@ymzhang>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-23 at 10:22 -0500, Christoph Lameter wrote:
>> No there is another way. Increase the allocator order to 3 for the
>> kmalloc-8192 slab then multiple 8k blocks can be allocated from one of the
>> larger chunks of data gotten from the page allocator. That will allow slub
>> to do fast allocs.

On Sat, Jan 24, 2009 at 4:55 AM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
> After I change kmalloc-8192/order to 3, the result(pinned netperf UDP-U-4k)
> difference between SLUB and SLQB becomes 1% which can be considered as fluctuation.

Great. We should fix calculate_order() to be order 3 for kmalloc-8192.
Are you interested in doing that?

On Sat, Jan 24, 2009 at 4:55 AM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
> But when trying to increased it to 4, I got:
> [root@lkp-st02-x8664 slab]# echo "3">kmalloc-8192/order
> [root@lkp-st02-x8664 slab]# echo "4">kmalloc-8192/order
> -bash: echo: write error: Invalid argument

That's probably because max order is capped to 3. You can change that
by passing slub_max_order=<n> as kernel parameter.

On Sat, Jan 24, 2009 at 4:55 AM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
> Comparing with SLQB, it seems SLUB needs too many investigation/manual finer-tuning
> against specific benchmarks. One hard is to tune page order number. Although SLQB also
> has many tuning options, I almost doesn't tune it manually, just run benchmark and
> collect results to compare. Does that mean the scalability of SLQB is better?

One thing is sure, SLUB seems to be hard to tune. Probably because
it's dependent on the page order so much.
