From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 23:53:13 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715235313.69897131@zanzibar.2ka.mipt.ru>
References: <1089898303.6114.859.camel@uganda>
	<1089898595.6114.866.camel@uganda>
	<1089902654.1029.23.camel@jzny.localdomain>
	<1089905244.6114.887.camel@uganda>
	<1089907622.1027.48.camel@jzny.localdomain>
	<1089910760.6114.967.camel@uganda>
	<1089912285.1028.93.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089912285.1028.93.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15 Jul 2004 13:24:45 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2004-07-15 at 12:59, Evgeniy Polyakov wrote:
> 
> > Userspace is too slow.
> > It can only initiate master's failover, load balancing is a good
> > example here - userspace _itself_ can not control real time traffic.
> 
> What is it that CARP does that couldnt be achieved by VRRP? 

I will answer a question by question, sorry.
Has vrrp some authentification mechanism?
Can it be used over IPv6? (CARP also can't but it is _very_ easy to
add, I just don't have IPv6 network setup to test).
May someone use vrrp in private commercial enviroment without fear of
being convicted?

> VRRP is implemented in user space. As a user myself i can assure you
> even with heartbeats at 100ms granularity i have seen no issues which
> can be blamed on the fact it runs on user space. And i have used it in
> fairly large setups.
> 
> > ct_sync module does this.
> > It uses connection tracking and sends firewall state across slaves.
> > CARP is separate by design - anyone may "attach" to master/slave
> > failover.
> 
> 
> Can you explain a little more what you mean by "attching" to
> master/slave?

Consider using some abstraction layer which makes some decisions based
on knowledge of current HA state.

> I hope you are not saying that that this ct_sync thing sends 
> every piece of connection tracking state across. That would be a
> collosal waste.

It looks like we do not understand each other :)
Here is the explanation of the ct_sync:
http://cvs.netfilter.org/netfilter-ha/README?rev=1.2&content-type=text/vnd.viewcvs-markup

Harald Welte will have a talk about ct_sync at OLS.

> > > This is an example of a rich application and further justification
> > > for it to live in user space.
> > 
> > If it will live in userspace, it just can not control realtime
> > traffic and even provide some mechanism to achive this.
> 
> What do you mean realtime traffic?
> Is it something that can be achieved by qos prioritization?

Yes it can. But who will control prioritization mechanism?
Maybe userspace.
But with such approach we need to create each time we need kernel access
a kernel agent with it's own kernel<->user protocol, it's own connect
to master/slave arbiter...
With CARP just create one function in kernelspace and register it in
CARP using provided mechanism.

> > > It is valuable, just doesnt belong to the kernel.
> > > BTW, i saw some claim that this is patent-free as opposed to VRRP?
> > > I do hope it takes off.  What exactly is the patent issue that was
> > > at stake? I couldnt tell from the song lyrics ;->
> > 
> > :) Cisco + hsrp == vrrp, but the former is patented.
> > Here is quote from Ryan McBride, an author of the CARP:
> > 
> > * P.S. If anyone has concerns about the Cisco's patent #5,473,599
> > and how their claim that it applies to VRRP has forced us to design
> > our own incompatible protocol, don't talk to us. Instead, call
> > Cisco's lawyer at 408-525-9706, or email him: rbarr@cisco.com *
> > 
> 
> In the end CISCO is going to be the loser in this of because 
> something like CARP will take off and it cant talk to them. At the
> moment though they do have the market so interoping with them is
> valuable.

It is just marketing...
The better software the more market it can eat. Theoretically...

> > > One valuable thing that could be done is while still avoiding any
> > > patent issues make it interop with VRRP.
> > 
> > VRRP is not secure, it is protocol dependent, it is not free...
> 
> I was talking more from a deployment side rather than technology.
> The gentleman who now owns the VRRP daemon in Linux, Alexander Cassen,
> i believe had a chat with this Cisco lawyer and if my understanding is
> correct the main contention is CISCO is worried some idiot will sue
> them by writting a similar patent i.e the patent was not to have
> something to impose on other people rather a protection.  I could be

In theory practice and theory are the same, but in practice they are
different. (c) Larry McVoy.

Why use not good software and has even theoretical possibility to be 
convicted when we have free successor( :) I said it? Nah... ).

> wrong. BTW, I am still not sure what the differences are that make
> CARP patent-free. In other words, I wouldnt bet at this point that if
> someone wanted to go after you for HSRP patent infrigement that it
> would be impossible. In any case i fully support the effort.

I have great confidence that Theo de Raadt will not include non
patent-free code in OpenBSD.

> BTW, I thought you could make VRRP secure.

And protocol independent, and absolutely, even theoretically free, just
better and different. It was already done by Ryan McBride.
But he also changed name :)

I believe it was Moor's law, that said than people always have time to
rewrite project from scratch, but never have time to properly
coordinate efforts and create good thing at the first time.
Or something like this...

> cheers,
> jamal


	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt
