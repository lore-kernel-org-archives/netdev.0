From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 26 Jan 2004 22:25:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075173905.1039.65.camel@jzny.localdomain>
References: <20040125164431.GA31548@louise.pinerecords.com>
	 <1075058539.1747.92.camel@jzny.localdomain>
	 <20040125202148.GA10599@usr.lcm.msu.ru>
	 <1075074316.1747.115.camel@jzny.localdomain>
	 <20040126001102.GA12303@usr.lcm.msu.ru>
	 <1075086588.1732.221.camel@jzny.localdomain>
	 <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <1075127396.1746.370.camel@jzny.localdomain>
	 <20040126174122.GB20001@usr.lcm.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040126174122.GB20001@usr.lcm.msu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-01-26 at 12:41, Vladimir B. Savkin wrote:
> On Mon, Jan 26, 2004 at 09:29:56AM -0500, jamal wrote:
[..]
> 
> Over here every good networking engineer I have talked to knows this :)

This may be true but its like sticking a finger in the air
and saying the "wind blows south" ;-> Data my friend.

> > Thats what i was assuming. Shaping alone is insufficient as well.
> 
> I don't quite understand what you mean here.
> Ultimately, any packet will land in some leaf qdisc,
> where there is a queue of some maximum size.
> If a sender does not reduce its rate, queue overflows, and we drop.
> But in my experience this rarely happens with TCP. I think that sender
> just see measured RTT increase and reduce its rate or shrinks
> its window. I don't know modern TCP implementations in detail, 
> but I can see it works.

We are saying the same thing. And we are also digressing from the main
point. So lets drop this part if you dont mind.

> > So why cant you attach a ingress qdisc on eth1-2 and use policing to
> > mark excess traffic (not drop)? On eth0 all you do is based on the mark
> 
> And where to drop then?
> 

Look at the example i just typed.
In your case you dont need the patch i described; use the standard
ingress qdisc and mark with iptables.

> So, it's just like IMQ, but without that Q bit, only marking?
> 

Exactly.

> But how would I calculate guaranteed rate for a client?

Note how i used index 1 for the meter in the example i posted.
index 1 is only for one client.

> Suppose I have 100 clients connected, then I can only
> guarantee a 1/100th of the pipe to each. But if only 5 of them
> are active, then each can get 1/5th of the pipe.

Look at the way i had index 200 and 300 one for sharing within a
device and another for the whole system. 
You should also just be able to use marks and shape on egress.

> Round-robin mechanism such as wrr effectively adjusts rates in dynamic.
> I use two-layer hierarchy actually, by applying sfq to every wrr class,
> so a user can download a file and play Quake at the same time,
> with acceptable delays and no packet loss. At the same time,
> user that opens 1000 connections with some evil multithreaded downloader
> thing, has the same aggregate rate, but can't play Quake because
> of high latency.  It works wonderfully.
> 
> I suppose we can have a flavor of wrr that will not queue packets,
> only find over-active flows and mark or drop over-profile packets
> but 1) no such thing exist AFAIK and 2) it will not have separate
> queue for each user/flow, thus all flows will have same latency,
> only drop probabilities will differ.
> 
> So, it seems to me that IMQ fits nicely when there're some artificial
> bandwidth limits (as opposed to bandwidth of some physical interface)
> and no single egress interface for all flows to be shaped.

Look at that sample and then lets discuss further. I spent a long time
typing it (and wanna catch up with other email). I think we may be
gettin close.

cheers,
jamal
