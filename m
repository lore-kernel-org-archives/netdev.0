From: jamal <hadi@cyberus.ca>
Subject: Billing 2: WAS(Re: [PATCH 2/4] deferred drop, __parent workaround,
	reshape_fail , netdev@oss.sgi.com ,
Date: 22 Aug 2004 11:38:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093189084.1039.137.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	 <1092401484.1043.30.camel@jzny.localdomain>
	 <20040816072032.GH15418@sunbeam2>
	 <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org>
	 <1092743526.1038.47.camel@jzny.localdomain>  <41220AEA.20409@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8 <sandr8_NOSPAM_@crocetta.org>
In-Reply-To: <41220AEA.20409@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-17 at 09:40, sandr8 wrote:
> jamal wrote:

> >Dropping packets at the policer is policy definition. Dropping packets
> >at the qdisc due to full queue is an accident. An accident that in
> >a good system shouldnt happen.
> >
> why it should not happen in a good system?
> it is an accident that is a sympthom of something. when we
> encounter that accident we detect that "sympthom" at the
> scheduler. the way the scheduler reacts to that sympthom
> is imho part of the policy. 

By "good system" i mean one with no resource bottlenecks or one that
deals elegantly deals with bottlenecks.

1) A packet that is dropped because a queue is found to be full on
enqueue() is an exception handling. Typically such a drop is a result of
a bottleneck. In this specific case more than likely a bus overload (at
least where i have seen it 100% of the time). My talk at SUCON will
touch on some experiences in this area.
In such a case you want the top layer to treat such behavior differently
by perhaps backing off for a short while - i.e this is an internal
resource congestion. Thats why TCP needs to be lied to with _BYPASS.

2) I see that as different from policing or firewalling where i have
actually  managed the resource myself and told the system to drop the
packet. 

Essentially in #1 i am providing more intelligence to TCP so it can
do smarter congestion control than it would have done otherwise
(suing whatever std congestion algorithms ask it to). This is extremely
valuable (and i think Linux is the only OS which  does this).
In #2 i dont want TCP to bypass its standard congestion
control algorithm;at some point it discovers it and thinks theres
congestion on the network - we just dont help.

Not sure if that makes sense.

> i'm somehow advocating that
> the policer is something more than the mere filter, but the
> filter + that part of the scheduler that decides what to drop...
> from that viewpoint there is no big difference between
> the filter drop and the "accidental drop" performed
> nevertheless in compliance with a given policy.

Refer to what i said above.


cheers,
jamal
