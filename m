From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 08:33:15 -0400
Message-ID: <1114173195.7679.30.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com>  <m1hdhzyrdz.fsf@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1hdhzyrdz.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 13:36 +0200, Andi Kleen wrote:
> Greg Banks <gnb@sgi.com> writes:
> >
> > An inordinate amount of CPU is being spent running around polling the
> > device instead of dealing with the packets in IP, TCP and NFS land.
> > By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
> > box with slower CPUs.
> 
> We have seen similar behaviour. With NAPI some benchmarks run
> a lot slower than on a driver on the same hardware/NIC without NAPI.

They should not run slower - but they may consume more CPU.

> This can be even observed with simple tests like netperf single stream
> between two boxes.
> 

Yes, slow traffic coming into the system would chew more CPU if you have
a fast CPU ;-> You should know this Andi, but let me explain the reason
for about the 100th time:
If your CPU is fast enough such that the interupt only causes 1-2
packets to be processed before reenabling, then you will have anywhere
between 1-2 extra IO calls (recall dis/reenabling interupts) - this will
be noticed in the CPU % chewed. It shouldnt be really a lot of CPU.
If you use non-NAPI then you dont have the extra IO happening and
therefore you will see less CPU used at those rates.
OTOH, Try more than 1 netperfs and it becomes beneficial to have NAPI
around. 
Yes, for low rates - this will make some of those benchmarks look bad.
But for such cases you can use mitigation in addition to NAPi - except
your latency in the benchmark will now look bad ;->

> There seems to be also some problems with bidirectional traffic, although
> I have not fully tracked them down to NAPI yet.
> 

doubt it has to do with NAPI.

> There is definitely some problem in NAPI land ...
> 

this is a design choice - a solution could be created to "fix" this but
hasnt happened because there has not been a good reason to complicate
things. The people who are bitching about this are benchmarkers who want
to win at both high and low rates and they are not happy because while
they can win at high rates, they cant at low rates.

cheers,
jamal
