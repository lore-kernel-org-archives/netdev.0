From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 14 Aug 2004 17:21:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092518370.2876.3.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain> <411CCB98.4080904@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>,
        devik@cdi.cz, shemminger@osdl.org, kaber@trash.net,
        rusty@rustcorp.com.au, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8@crocetta.org
In-Reply-To: <411CCB98.4080904@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[please wrap your email at about 76 characters; makes it easier to
respond to]

On Fri, 2004-08-13 at 10:09, sandr8 wrote:
> jamal wrote:

> >1) You cant change the enqueue/dequeue API just because one qdisc
> >doesnt seem to use it right. Whats all that contrack stuff doing in 
> >dev.c and pkt sched areas?
> >
> the conntrack stuff (actually that little part of code that adds 
> unbilling to ACCT in case of a drop) is something that comes later 
> (patch 4) and is not in the pkt sched part. please, don't let it 
> divert your mind from the real point. just forget it for the moment...
>  [in any case it is _not_ in the pkt sched area and as i said in mail 
> 4/4 i don't like to put the variables into dev.c, that's why i am 
> there asking for alternatives]

This actually seems to be the core issue. 
Correct me if i misunderstood what you are trying to achieve: 
Somewhere above, the netfilter code bills some packet. Packet gets 
all the way to the scheduler on egress.
Scheduler drops packet although it has been billed already.
You being a man looking for justice ;-> decides that was unfair and
you are trying to undo it. Is this accurate?

Also is their a corrective factor that happens once the _accounting_ 
data has been shipped? Example: 
- account for packet
- ship accounting data to some billing server
- oops, unbill
- what now?

BTW, what happens if you clone the packet below netfilter and send
several copies of it possibly over several different interfaces? This
may happen with tc extensions.
I think accounting is important - especially if it is almost free with
contracking.
 
Lets talk about this issue first instead of confusing it with everything
else you have in other patches.

cheers,
jamal
