From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sat, 31 Jan 2004 21:52:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040131185231.GA2608@usr.lcm.msu.ru>
References: <20040125164431.GA31548@louise.pinerecords.com> <1075058539.1747.92.camel@jzny.localdomain> <20040125202148.GA10599@usr.lcm.msu.ru> <1075074316.1747.115.camel@jzny.localdomain> <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <1075127396.1746.370.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075127396.1746.370.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal, I think you did not understand the role of IMQ in my setup.

Here is my diagram:


> > 
> >                     +---------+       +-ppp0- ... - client0
> >                     |         +-eth1-<+-ppp1- ... - client1
> > Internet ----- eth0-+ router  |     . . . . . . . .
> >                     |         +-eth2-<  . . . . . .
> >                     +---------+       +-pppN- ... - clientN
> > 		    
> > 

Please notice this:

> > Traffic flows from internet to clients. 
This means from _left_ to _right_ :)


And here is what you suggest:


> So why cant you attach a ingress qdisc on eth1-2 and use policing to
> mark excess traffic (not drop)? On eth0 all you do is based on the mark
> you stash them on a different class i.e move the stuff you have on
> IMQ0 to eth0.
> 

But in my case, eth0 is an ingress device, and eth1 and eth2 are 
(physical) egress devices.
For traffic going other direction (from right to left) I could do
without IMQ, as you suggest. 
But on the right side of a diagram we can see no single device
(physical or virtual) we can attach qdisc to, hence the need for IMQ.


> Example on ingress:
> 
> meter1=" police index 1 rate $CIR1"
> meter1a=" police index 2 rate $PIR1"
> 
> index 2 is shared by all flows for default.
> index 1 (and others) is guaranteeing rate (20Kbps) for each of the flows
> etc.
> Look for example at examples/Edge32-ca-u32
> 
> The most important thing to know is that policers can be shared across 
> devices, flows etc using the "index" operator.
> 

Ok, this looks like typical diffserv setup, as they described in RFCs.
It doesn't assure fair bandwith sharing between active clients. 
We just can't decide what traffic is excess using some predetermined
rate, we must look for current rates of other clients and penalize those
who use unfair shares. Such meters and policers could exist but I don't
know any. wrr and htb can do it, but they use queuing and round-robin
to achive fairness, not meters and policers.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
