From: Andi Kleen <ak@muc.de>
Subject: Re: NAPI, e100, and system performance problem
Date: 22 Apr 2005 19:21:08 +0200
Message-ID: <20050422172108.GA10598@muc.de>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408> <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain> <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de> <1114173195.7679.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Fri, 22 Apr 2005 19:21:08 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114173195.7679.30.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 08:33:15AM -0400, jamal wrote:
> On Fri, 2005-22-04 at 13:36 +0200, Andi Kleen wrote:
> > Greg Banks <gnb@sgi.com> writes:
> > >
> > > An inordinate amount of CPU is being spent running around polling the
> > > device instead of dealing with the packets in IP, TCP and NFS land.
> > > By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
> > > box with slower CPUs.
> > 
> > We have seen similar behaviour. With NAPI some benchmarks run
> > a lot slower than on a driver on the same hardware/NIC without NAPI.
> 
> They should not run slower - but they may consume more CPU.

They actually run slower.

Now before David complains this was with old 2.6 kernels and I dont have
time right now to rerun the benchmarks, but at least I dont think
there was ever any patch addressing these issues.

> 
> > This can be even observed with simple tests like netperf single stream
> > between two boxes.
> > 
> 
> Yes, slow traffic coming into the system would chew more CPU if you have
> a fast CPU ;-> You should know this Andi, but let me explain the reason
> for about the 100th time:

No, the performance of the data transfer was actually slower. CPU time
was not the problem, Opterons have enough of that ...

> this is a design choice - a solution could be created to "fix" this but
> hasnt happened because there has not been a good reason to complicate
> things. The people who are bitching about this are benchmarkers who want
> to win at both high and low rates and they are not happy because while
> they can win at high rates, they cant at low rates.

My impression is that NAPI seems to be more optimized for a rather
obscure work load (routing), while it does not seem to be that 
great on the far more common server/client type workloads.
If that was a design choice then it was a bad design.

-Andi
