From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Mon, 19 Jan 2009 18:43:31 +1100
Message-ID: <200901191843.33490.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161746.25205.nickpiggin@yahoo.com.au> <4970CDB6.6040705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, matthew@wil.cx, matthew.r.wilcox@intel.com,
	chinang.ma@intel.com, linux-kernel@vger.kernel.org,
	sharad.c.tripathi@intel.com, arjan@linux.intel.com,
	andi.kleen@intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4970CDB6.6040705@hp.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 17 January 2009 05:11:02 Rick Jones wrote:
> Nick Piggin wrote:
> > OK, I have these numbers to show I'm not completely off my rocker to
> > suggest we merge SLQB :) Given these results, how about I ask to merge
> > SLQB as default in linux-next, then if nothing catastrophic happens,
> > merge it upstream in the next merge window, then a couple of releases
> > after that, given some time to test and tweak SLQB, then we plan to bite
> > the bullet and emerge with just one main slab allocator (plus SLOB).
> >
> >
> > System is a 2socket, 4 core AMD.
>
> Not exactly a large system :)  Barely NUMA even with just two sockets.

You're right ;)

But at least it is exercising the NUMA paths in the allocator, and
represents a pretty common size of system...

I can run some tests on bigger systems at SUSE, but it is not always
easy to set up "real" meaningful workloads on them or configure
significant IO for them.


> > Netperf UDP unidirectional send test (10 runs, higher better):
> >
> > Server and client bound to same CPU
> > SLAB AVG=60.111 STD=1.59382
> > SLQB AVG=60.167 STD=0.685347
> > SLUB AVG=58.277 STD=0.788328
> >
> > Server and client bound to same socket, different CPUs
> > SLAB AVG=85.938 STD=0.875794
> > SLQB AVG=93.662 STD=2.07434
> > SLUB AVG=81.983 STD=0.864362
> >
> > Server and client bound to different sockets
> > SLAB AVG=78.801 STD=1.44118
> > SLQB AVG=78.269 STD=1.10457
> > SLUB AVG=71.334 STD=1.16809
> >
>  > ...
> >
> > I haven't done any non-local network tests. Networking is the one of the
> > subsystems most heavily dependent on slab performance, so if anybody
> > cares to run their favourite tests, that would be really helpful.
>
> I'm guessing, but then are these Mbit/s figures? Would that be the sending
> throughput or the receiving throughput?

Yes, Mbit/s. They were... hmm, sending throughput I think, but each pair
of numbers seemed to be identical IIRC?


> I love to see netperf used, but why UDP and loopback?

No really good reason. I guess I was hoping to keep other variables as
small as possible. But I guess a real remote test would be a lot more
realistic as a networking test. Hmm, but I could probably set up a test
over a simple GbE link here.  I'll try that.


> Also, how about the
> service demands?

Well, over loopback and using CPU binding, I was hoping it wouldn't
change much... but I see netperf does some measurements for you. I
will consider those in future too.

BTW. is it possible to do parallel netperf tests?


