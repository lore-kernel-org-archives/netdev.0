From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 02 Feb 2005 09:05:06 -0500
Message-ID: <1107353106.1098.65.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <41FEB3AE.3090400@dsl.pipex.com>
	 <1107258578.1095.570.camel@jzny.localdomain>
	 <41FF97E9.7040501@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <41FF97E9.7040501@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-02-01 at 09:53, Andy Furniss wrote:
> jamal wrote: 
> > I know for a while the Bart howto was mislabeling the meaning of
> > policing - not sure about shaping. 
> > Shaping has a precise definition that involves a queue and a
> > non-working-conserving scheduler in order to rate control. This doesnt
> > matter where it happens (egress or ingress). Policing on the other hand
> > is work conserving etc.
> 
> Ok, but shaping to LARTC posters means being able to classify traffic 
> and set up sharing/priorotising of classes. 
>
> This is the reason most need 
> to be able to queue - they want to use htb/hfsc for complicated setups 

Close - but you are missing the rate control requirement. 
You can do the above with prio qdisc for example but that does not
equate to shaping. Understood about Lartc users definitions. However,
note that they are influenced by what people tell them or what people
write in docs. Help in making sure the redefinition doesnt propagate.
Theres a very precise meaning to shaping and it is _exactly_ the way i
described it above. Clue people who ask questions.

> and until now were not aware that it was even possible to replicate this 
> in policers 

I am sure i have written about 50 emails on this topic over the last 5
years;->  look at the archives. I even joked about it here:
http://www.cyberus.ca/~hadi/patches/action/README over 2 years ago.
look at the text reading "it must be the summer heat again; weve had
someone doing that every year around summer"
Unfortunately people who are writting docs havent picked it up for
whatever reasons. I am hoping we finaly get this documented somewhere.
Can you help fix this?

> and if it becomes feasable it will probably appear daunting 
> to do compared with HTB and all the existing docs/scripts.
> 

>From a usability perspective i agree with you. 
Its still doable is all i can say ;-> (but you are correct in that it
may not be for the weak hearts)
As a reminder of some of the big discussions on shared and hierachical
policing - look at the many many discussions I had with devik on this
topic a few years back.
It resulted in the birth of HTB (which is essentially a hierachy of the
same token bucket meters used in policers; hierachical shared policers
are doable - look at iproute2/examples/diffserv). HTB otoh has proven
useful due to simplicty - so it stands on its own merit now.
I think there may be peculiar occasions where you may need to have
queues to shape traffic to a local app - but thats peculiar. 

> For me, I think queuing and dropping is better than just dropping, you 
> can affect tcp by delaying eg. 1 ack per packet rather than delayed acks 
> and clocking out the packets helps smooth burstiness, 

True - but i question the usefulness of localy terminating TCP packets
being shaped. For packets being forwarded, the shaping happens on
egress.

> which hurts 
> latency if you are doing traffic control from the wrong end of the 
> bottleneck.
> 

Not sure i followed the latency connection.

> As long as I could use netfilter to mark/classify connections then I 
> think I can sort my setup, don't know about others.
> 
> 

Great. yes, you can.

> > Are pre/post routing sufficient as netfilter hooks for your case?
> 
> Yes but depends on where in pre/postrouting. For me after/before nat, as 
> I say above though I could workaround if I classify connections with 
> netfilter. For others as long as they can filter on a mark/classify set 
> in forward, then I think it will be OK for them.
> 

You can mark in netfilter or even in tc and use those marks in both
places.


> I am not sure what exactly can can't be done in your example:
>
>  ># redirect all IP packets arriving in eth0 to dummy0
>  ># use mark 1 --> puts them onto class 1:1
>  >$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
>  >match u32 0 0 flowid 1:1 \
> 
> What I can do here depends where it hooks packets.
> 
>  >action ipt -j MARK --set-mark 1 \
> 
> I don't know what table I am using - may be OK as long as I can test for 
> a mark I made earlier in the egress dummy case or test connmark/state I 
> set for that connection in the ingress case.
> 

That would be doable. Thanks for taking the time Andy.

cheers,
jamal
