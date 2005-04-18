From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 18 Apr 2005 16:26:07 -0400
Message-ID: <1113855967.7436.39.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504180943290.15052@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-18-04 at 09:55 -0700, Arthur Kepner wrote:
> On Sun, 17 Apr 2005, Brandeburg, Jesse wrote:
> 
> > ......
> > _conclusion_
> > 
> > Is there any way we can configure how soon or often to be polled
> > (called)? For 100Mb speeds at worst we can get about one 64 byte packet
> > every 9us (if I did my math right) and since the processors don't take
> > that long to schedule NAPI, process a packet and handle an interrupt, we
> > just overload the system with interrupts going into and out of napi
> > mode.  In this case I only have one adapter getting scheduled.
> > 
> 
> I'll just chime in to say that I've seen similar behavior,
> (but with a very different system.)
> 

It would _help_ a great deal if people collect data and post.
What was this other system? Was it running e100 as well? etc etc

> The problem with NAPI is (quoting a co-worker) that it
> relies on an "accident of timing".
> 

geez, that almost sounds like an insult. spank your coworker for me with
something sharp (i hope s/he doesnt enjoy it)

> If the CPU speed, time to complete a PIO, and the inter-
> packet arrival time are "just so", then a system (or at
> least one of its CPUs) can be kept very busy even when
> it's not receiving data from the network at a particularly
> high rate.
> 

again, it would help if you actually provided data - this sounds like
hand waving to me. 
The only known thing we are aware of is that if you have slow PIO at low
packet rates you will chew more CPU - the reason is simple: if you do 1
packet per interupt you will have one more IO per packet than if you
didnt use NAPI; at about 2.5 packets or so you start benefiting from the
amortization of IO. This issue has been discussed many many times at
netdev. There has been no good reason thus far to complicate things by
"fixing" it.  Go to MSI capable NICs if you are really concerned.

> The simple feedback mechanism used by NAPI is good at
> balancing latency and throughput, but it doesn't have
> any way of recognizing when system resources are being
> poorly utilized.

How do you recognize when system resources are being poorly utilized?
If you know the answer to that then you need to fix things at the
softirq scheduling level - not at NAPI (that would be the wrong spot)

>  It would be nice if interrupt coalesence
> could be used by NAPI (or maybe by NAPI_2 ?) in this sort
> of situation.
> 

You can add coalescing as is doable by e1000 for example - but that
shouldnt solve the problem you allude to - that of "system resources are
being poorly utilized" .

cheers,
jamal

PS:- if you want to help please post data.
