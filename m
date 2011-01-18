From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Tue, 18 Jan 2011 22:13:33 +0200
Message-ID: <20110118201333.GD18760@redhat.com>
References: <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D35ECE2.4040901@hp.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> >So it won't be all that simple to implement well, and before we try,
> >I'd like to know whether there are applications that are helped
> >by it. For example, we could try to measure latency at various
> >pps and see whether the backpressure helps. netperf has -b, -w
> >flags which might help these measurements.
> 
> Those options are enabled when one adds --enable-burst to the
> pre-compilation ./configure  of netperf (one doesn't have to
> recompile netserver).  However, if one is also looking at latency
> statistics via the -j option in the top-of-trunk, or simply at the
> histogram with --enable-histogram on the ./configure and a verbosity
> level of 2 (global -v 2) then one wants the very top of trunk
> netperf from:
> 
> http://www.netperf.org/svn/netperf2/trunk
> 
> to get the recently added support for accurate (netperf level) RTT
> measuremnts on burst-mode request/response tests.
> 
> happy benchmarking,
> 
> rick jones
> 
> PS - the enhanced latency statistics from -j are only available in
> the "omni" version of the TCP_RR test.  To get that add a
> --enable-omni to the ./configure - and in this case both netperf and
> netserver have to be recompiled.


Is this TCP only? I would love to get latency data from UDP as well.

>  For very basic output one can
> peruse the output of:
> 
> src/netperf -t omni -- -O /?
> 
> and then pick those outputs of interest and put them into an output
> selection file which one then passes to either (test-specific) -o,
> -O or -k to get CVS, "Human" or keyval output respectively.  E.G.
> 
> raj@tardy:~/netperf2_trunk$ cat foo
> THROUGHPUT,THROUGHPUT_UNITS
> RT_LATENCY,MIN_LATENCY,MEAN_LATENCY,MAX_LATENCY
> P50_LATENCY,P90_LATENCY,P99_LATENCY,STDDEV_LATENCY
> 
> when foo is passed to -o one will get those all on one line of CSV.
> To -O one gets three lines of more netperf-classic-like "human"
> readable output, and when one passes that to -k one gets a string of
> keyval output a la:
> 
> raj@tardy:~/netperf2_trunk$ src/netperf -t omni -j -v 2 -- -r 1 -d rr -k foo
> OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost
> (127.0.0.1) port 0 AF_INET : histogram
> THROUGHPUT=29454.12
> THROUGHPUT_UNITS=Trans/s
> RT_LATENCY=33.951
> MIN_LATENCY=19
> MEAN_LATENCY=32.00
> MAX_LATENCY=126
> P50_LATENCY=32
> P90_LATENCY=38
> P99_LATENCY=41
> STDDEV_LATENCY=5.46
> 
> Histogram of request/response times
> UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> TEN_USEC      :    0: 3553: 45244: 237790: 7859:   86:   10:    3:    0:    0
> HUNDRED_USEC  :    0:    2:    0:    0:    0:    0:    0:    0:    0:    0
> UNIT_MSEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> TEN_MSEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
> >100_SECS: 0
> HIST_TOTAL:      294547
