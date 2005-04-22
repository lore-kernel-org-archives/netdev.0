From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 14:18:22 -0400
Message-ID: <1114193902.7978.39.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <1114173195.7679.30.camel@localhost.localdomain>
	 <20050422172108.GA10598@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050422172108.GA10598@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 19:21 +0200, Andi Kleen wrote:
> On Fri, Apr 22, 2005 at 08:33:15AM -0400, jamal wrote:
[..]
> > They should not run slower - but they may consume more CPU.
> 
> They actually run slower.
> 

Why do they run slower? There could be 1000 other variables involved?
What is it that makes you so sure it is NAPI?
I know you are capable of proving it is NAPI - please do so.

> Now before David complains this was with old 2.6 kernels and I dont have
> time right now to rerun the benchmarks, but at least I dont think
> there was ever any patch addressing these issues.
> 

It would be helpful if you use new kernels of course - that reduces the
number of variables to look at. 

> > this is a design choice - a solution could be created to "fix" this but
> > hasnt happened because there has not been a good reason to complicate
> > things. The people who are bitching about this are benchmarkers who want
> > to win at both high and low rates and they are not happy because while
> > they can win at high rates, they cant at low rates.
> 
> My impression is that NAPI seems to be more optimized for a rather
> obscure work load (routing), while it does not seem to be that 
> great on the far more common server/client type workloads.
> If that was a design choice then it was a bad design.
> 

There is only one complaint I have ever heard about NAPI and it is about
low rates: It consumes more CPU at very low rates. Very low rates
depends on how fast your CPU can process at any given time. Refer to my
earlier email. Are you saying low rates are a common load?

The choices are: a) at high rates you die or b) at _very low_ rates
you consume more CPU (3-6% more depending on your system). 

Logic says lets choose a). You could overcome b) by turning on
mitigation at the expense of latency. We could "fix" at a cost of 
making the whole state machine complex - which would be defeating  
the " optimize for the common".
 
You are the first person i have heard that says NAPI would be slower
in terms of throughput or latency at low rates. My experiences is there
is no difference between the two at low input rate.  It would be
interesting to see the data.

>> Note, this would entirely solve what Andi and the SGI people are 
>> talking about.
> 
> Perhaps, but Linux has to perform well on old hardware too.
> New silicon is not a solution.
> 

I dont see any reason to "fix" anything (note my use of quotes) on old 
hardware. You have a workaround. 
OTOH, provide data to prove otherwise - we all want Linux to be the best.

cheers,
jamal
