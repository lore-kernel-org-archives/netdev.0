From: Luca Deri <deri@ntop.org>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond	Device
 Polling
Date: Wed, 07 Apr 2004 09:03:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4073A7AF.5060401@ntop.org>
References: <20040330142354.GA17671@outblaze.com>	<1081033332.2037.61.camel@jzny.localdomain>	<c4rvvv$dbf$1@sea.gmane.org>	<1081261126.1047.6.camel@jzny.localdomain> <16498.52551.712261.214192@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com,
        ntop-misc@fuji.unipi.it
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16498.52551.712261.214192@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:

>jamal writes:
>
> > I didnt follow that discussion; archived for later entertaining reading.
> > My take on it was it is 2.6.x related and in particular the misbehavior
> > observed has to do with use of rcu in the route cache.
> > 
> > > It appears this problem became worse in 2.6 with HZ=1000, because now
> > > the napi rx softirq work is being done 10X as much on return from the
> > > timer interrupt.  I'm not sure if a solution was reached.
> > 
> > Robert?
>
> Well it's a general problem controlling softirq/user and the RCU locking
> put this on our agenda as the dst hash was among the first applications 
> to use the RCU locking. Which in turn had problem doing progress in hard 
> softirq environment which happens during route cache DoS.
>
> NAPI is a part of RX_SOFTIRQ which is well-behaved. NAPI addresses only 
> irq/sofirq problem and is totally innocent for do_sofirq() run from other 
> parts of kernel causing userland starvation.
>
> Under normal hi-load conditions RX_SOFTIRQ schedules itself when the
> netdev_max_backlog is done. do_softirq sees this and defers execution
> to ksoftirqd and things get under (scheduler) control.
>
> During route DoS, code that does a lot do_softirq() is run for hash and 
> fib-lookup, GC etc. The effect is that ksoftirqd is more or less bypassed.
> Again it's a general problem... We are just the unlucky guys getting 
> into this.
>
> I don't know if packet capture tests done by Luca ran into this problems.
> A profile could have helped...
>  
>

Robert,
yes I run into this problems and I have solved using the RTIRQ kernel patch.

Cheers, Luca

> Cheers.
>						--ro 
>  
>


-- 
Luca Deri <deri@ntop.org>	http://luca.ntop.org/
Hacker: someone who loves to program and enjoys being
clever about it - Richard Stallman
