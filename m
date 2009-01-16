From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 15:53:50 +0800
Message-ID: <1232092430.11429.52.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, andi.kleen@intel.com,
	suresh.b.siddha@intel.com, harita.chilukuri@intel.com,
	douglas.w.styner@intel.com, peter.xihong.wang@intel.com,
	hubert.nueckel@intel.com, chris.mason@oracle.com,
	srostedt@redhat.com, linux-scsi@vger.kernel.org,
	andrew.vasquez@qlogic.com, anirban.chakraborty@qlogic.com
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090116065546.GJ31013@parisc-linux.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-01-15 at 23:55 -0700, Matthew Wilcox wrote:
> On Fri, Jan 16, 2009 at 05:46:23PM +1100, Nick Piggin wrote:
> > Intel's OLTP shows SLQB is "neutral" to SLAB. That is, literally within
> > their measurement confidence interval. If it comes down to it, I think we
> > could get them to do more runs to narrow that down, but we're talking a
> > couple of tenths of a percent already.
> 
> I think I can speak with some measure of confidence for at least the
> OLTP-testing part of my company when I say that I have no objection to
> Nick's planned merge scheme.
> 
> I believe the kernel benchmark group have also done some testing with
> SLQB and have generally positive things to say about it (Yanmin added to
> the gargantuan cc).
We did run lots of benchmarks with SLQB. Comparing with SLUB, one highlighting of
SLQB is with netperf UDP-U-4k. On my x86-64 machines, if I start 1 client and 1 server
process and bind them to different physical cpus, the result of SLQB is about 20% better
than SLUB's. If I start CPU_NUM clients and the same number of servers without binding,
the results of SLQB is about 100% better than SLUB's. I think that's because SLQB
doesn't pass through big object allocation to page allocator.
netperf UDP-U-1k has less improvement with SLQB.

The results of other benchmarks have variations. They are good on some machines,
but bad on other machines. However, the variation is small. For example, hackbench's result
with SLQB is about 1 second than with SLUB on 8-core stoakley. After we worked with
Nick to do small code changing, SLQB's result is a little better than SLUB's
with hackbench on stoakley.

We consider other variations as fluctuation.

All the testing use default SLUB and SLQB configuration.

> 
> Did slabtop get fixed to work with SLQB?
> 

