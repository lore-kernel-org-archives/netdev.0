From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 09 Jun 2004 21:47:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086832074.1207.53.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <1086722317.1023.18.camel@jzny.localdomain>
	 <20040608195238.GA21089@bougret.hpl.hp.com>
	 <1086728139.1023.71.camel@jzny.localdomain>
	 <20040608220109.GA24536@bougret.hpl.hp.com>
	 <1086752809.1049.62.camel@jzny.localdomain>
	 <20040609174021.GA26159@bougret.hpl.hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040609174021.GA26159@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-09 at 13:40, Jean Tourrilhes wrote:
> On Tue, Jun 08, 2004 at 11:46:49PM -0400, jamal wrote:
> > > Most likely, the FIFOs will share the same memory pool on the
> > > card, so when a FIFO is full, most likely the other FIFOs will be full
> > > or close to it.
> > 
> > How do you reach such a conclusion?
> > There maybe packets of the same priority for longs periods of time.
> 
> If all the FIFO take from the same memory pool, when one FIFO
> is full, it means that the memory pool is exhausted. 

Is this how these things are designed?

> If the memory
> pool is exhausted, then you can't fill the other FIFOs.

So there are no bounds defined for each FIFO?
If yes, whoever designed those boards is on some really cheap crack.
Fire his or her ass.
If no, then please dont use this approach.
Put some limits to the FIFOs and use the strict priority scheme defined
(it seems by that standard).

> Yep. That's no worse than what we have today with a single
> FIFO in today's cards. Remember that amount of buffer on the card is
> limited, so we are not talking of an incredible number of packets in
> those FIFO. I'm 100% with Andy in suggesting to keep hardware FIFO as
> short as possible, precisely so that the TC scheduling is effective.
> If you let the card scheduler take over, it will screw up your
> TC scheduling no matter what, unless the card scheduler use the exact
> same scheduling as TC (which is unlikely for complex TC policies).

I am assuming it will use _exactly_ the same prioritization approiach;
even if bandwidth allocation is used in the scheduling, the
prioritization will match _exactly_ what the NIC does.

> If the card policy is to always drain the highest priority
> queue first, and you want to guarantee a minimum bandwidth for low
> priority traffic at the TC level, if you let the card scheduler do its
> business and always feed high priority traffic when it wants it, then
> there is no way you can guarantee your minimum bandwidth for low
> priority traffic.

You can. But the bigger question is do you care?

> 
> No, it's fine only if TC policy is "Always send from highest
> priority". If TC policy is different, then it's not fine at all.

Not really. Just pick any of the other schedulers which do bwidth
scheduling and map the priorities to the FIFO priorities. 

> You assume that the card scheduler will be configurable, and
> work as expected. Wait and see ;-)

I am assuming the only thing it can do is strict priority. I trust you
know more about how these cards look like - so when you express doubts
about the lack of configurability you are also putting doubts in me; but
let me say this: If you can have configurability such that you can
partition finite FIFOs one for each priority or for a set of priorities,
then you are set.

cheers,
jamal
