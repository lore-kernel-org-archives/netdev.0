From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP congestion schedulers
Date: Mon, 28 Mar 2005 15:51:17 -0800
Message-ID: <20050328155117.7c5de370@dxpl.pdx.osdl.net>
References: <421D30FA.1060900@ev-en.org>
	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	<20050309210442.3e9786a6.davem@davemloft.net>
	<4230288F.1030202@ev-en.org>
	<20050310182629.1eab09ec.davem@davemloft.net>
	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	<20050311201011.360c00da.davem@davemloft.net>
	<20050314151726.532af90d@dxpl.pdx.osdl.net>
	<m13bur5qyo.fsf@muc.de>
	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
	<20050322074122.GA64595@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, baruch@ev-en.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050322074122.GA64595@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 22 Mar 2005 08:41:22 +0100
Andi Kleen <ak@muc.de> wrote:

> On Mon, Mar 21, 2005 at 04:25:56PM -0500, John Heffner wrote:
> > On Sat, 19 Mar 2005, Andi Kleen wrote:
> > 
> > > Stephen Hemminger <shemminger@osdl.org> writes:
> > >
> > > > Since developers want to experiment with different congestion
> > > > control mechanisms, and the kernel is getting bloated with overlapping
> > > > data structure and code for multiple algorithms; here is a patch to
> > > > split out the Reno, Vegas, Westwood, BIC congestion control stuff
> > > > into an infrastructure similar to the I/O schedulers.
> > >
> > > [...]
> > >
> > > Did you do any benchmarks to check that wont slow it down?
> > >
> > > I would recommend to try it on a IA64 machine if possible. In the
> > > past we found that adding indirect function calls on IA64 to networking
> > > caused measurable slowdowns in macrobenchmarks.
> > > In that case it was LSM callbacks, but your code looks like it will
> > > add even more.
> > 
> > Is there a canonical benchmark?
> 
> For the LSM case we saw the problem with running netperf over loopback. 
> It added one or two hooks per packet, but it already made a noticeable
> difference on IA64 boxes.
> 
> On other systems it is unnoticeable.
> 
> > Would you really expect a single extra indirect call per ack to have a
> > significant performance impact?  This is surprising to me.  Where does the
> > cost come from?  Replacing instruction cache lines?
> 
> I was never quite clear. Some instruction stalls in the CPUs. 
> One not very good theory was that McKinley really likes
> to have its jump registers loaded early for indirect calls, and gcc
> doesn't even attempt this.
> 
> -Andi

Running on 2 Cpu Opteron using netperf loopback mode shows that the change is
very small when averaged over 10 runs. Overall there is 
a .28% decrease in CPU usage and a .96% loss in throughput.  But both those
values are less than twice standard deviation which was .4% for the CPU measurements
and .8% for the performance measurements.  I can't see it as a worth
bothering unless there is some big money benchmark on the line, in which case
it would make more sense to look at other optimizations of the loopback
path.
