From: jamal <hadi@cyberus.ca>
Subject: Re: Billing 3-1: WAS(Re: [PATCH 2/4] deferred drop, __parent
	workaround, reshape_fail , netdev@oss.sgi.com ,
Date: 23 Aug 2004 07:38:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093261128.1044.759.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
	 <1093191124.1043.206.camel@jzny.localdomain>
	 <4129BB3A.9000007@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <4129BB3A.9000007@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-23 at 05:39, sandr8 wrote:
> jamal wrote:
> 
> >On Tue, 2004-08-17 at 09:40, sandr8 wrote:
> >  
> >
> >Such packets are cloned or copied. I am going to assume the contrack
> >data remains intact in both cases. LaForge?
> >BTW, although i mentioned the multiple interfaces as an issue - thinking
> >a little more i see retransmissions from TCP as well (when enqueue drops
> >because of full queue) being a problem.
> >  
> >
> imho, the point maybe is that a scheduler should work at layer 3,
> am i wrong?
> i mean: i made the same question to myself and answered that
> the right level should be the third... this would account for tcp
> retransmissions as well as forward error corrections packets
> added by some application on top of udp, or retrasmissions by
> applications on udp... or... whatever...

Maybe state oughta be carried somehow from where the packets "starts"
(eg application/L4 level) or ingress of system. This may complicate
things - will need a lot more thinking (but is worth thinking about).

> maybe my reasoning is less foggy if i first answer to an other
> question:
> 
> >I think the issue starts with defining what resource is being accounted
> >for. In my view, you are accounting for both CPU and bandwidth.
> >Lets start by asking  What is the resource being accounted for?
> >  
> >
> i would like to account for the number of bytes sent to the wire
> on behalf of each flow :)

Ok, in this case, retransmissions have to be unbilled.
To rewind to what i said a few emails ago:
The best place to bill is by looking at what comes out of the box;->
Ok, we dont have that luxury in this case. So the next best place
is to do it at the qdisc level. Because only at that level do you
know for sure if packets made it out or not. 
Since contracking already does the job of marking the flow, then
thats the second part of your requirement "on behalf of each flow".
What we are doing now is hacking around to try and reduce the injustice.

Conclusion: The current way of billing is _wrong_. The better way is to
have contracking just mark and the qdisc decide on billing or unbilling.
Have a billing table somewhere indexed by flow that increments these
stats.

For now i think that focussing on just sch.drops++ in case of full 
queue will help.

Let me cut email here for readability.

cheers,
jamal
