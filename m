From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] TCP Vegas for 2.6
Date: Tue, 9 Mar 2004 19:03:31 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040309180331.GC11604@wotan.suse.de>
References: <20040308134542.62320cae@dell_ss3.pdx.osdl.net> <Pine.NEB.4.33.0403091234380.5230-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.33.0403091234380.5230-100000@dexter.psc.edu>
List-Id: netdev.vger.kernel.org

On Tue, Mar 09, 2004 at 12:52:14PM -0500, John Heffner wrote:
> On Mon, 8 Mar 2004, Stephen Hemminger wrote:
> 
> > On Mon, 8 Mar 2004 22:36:46 +0100
> > Andi Kleen <ak@suse.de> wrote:
> >
> > > > CONFIG options are of no use vendors who need to ship binary kernels.
> > >
> > > I can well see a vendor trading scalability for experimental non standard TCP
> > > algorithms that tend to be disabled anyways.
> >
> > If Vegas proves to be as reliable in Linux as BSD, it probably will be the
> > default.
> 
> I'm curious what you mean about BSD.

Agreed. All BSDs I'm aware of are far more conservative than Linux
in TCP algorithms: last time I checked they didn't even have
SACK/FACK or the fast retransmit for multiple packets per window 
algorithms.

> I would be very cautious about turning on Vegas by default.  In certain
> cases, it is exactly the right thing to do.  However, in many cases it is
> not.  Vegas will end up losing when competing against regular Reno-ish
> congestion control.  Vegas also has issues with timer granularity, and
> tuning its parameters can be quite tricky.  There are a number of unusual
> failure modes as well, such as responding to congestion on the reverse
> path, or caused by cross traffic.

It would be better to make it a per route flag than a global sysctl
at least.

Then you could use it for your speed critical high bandwidth WAN link 
(or whatever it turns out to be good at) and stay conservative and predictable
for everything else.

And the per TCB overhead everybody has to pay right now is quite big for 
such an experimental option.

-Andi
