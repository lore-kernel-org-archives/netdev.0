From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 10:30:17 -0400
Message-ID: <1219415417.4672.79.camel@localhost>
References: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080822005129.4697.77680.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080822.031654.29257013.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:47520 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbYHVOaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 10:30:21 -0400
Received: by rv-out-0506.google.com with SMTP id k40so457728rvb.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 07:30:21 -0700 (PDT)
In-Reply-To: <20080822.031654.29257013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-22-08 at 03:16 -0700, David Miller wrote:

> If it's just to tag traffic into different TX queues by priority,
> that's not very wise nor desirable.  What's the point?
> 
> The TX queues are useful for multiplexing traffic and seperating
> the locking and cpu overhead across execution entities in the
> system.  They can also be useful for virtualization, but that's
> not relevant in this discussion.
> 
> The TX queues, on the other hand, are not useful for exposing the
> round-robin or whatever algorithm that some cards just so happen to
> enforce fairness amongst the TX queues.  That's an implementation
> detail.
>
> The truth is, the only reason the RR prio scheduler got added was
> because Jamal and myself didn't understand very well how to use these
> multiqueue cards, or at least I didn't understand it.
> 

For the record, I was against the approach taken not the end goal. IIRC,
I was slapped around with a big fish at the time and so i got out of the
way. I still dont like it;->

There are two issues at stake:
1) egress Multiq support and the desire to have concurency based on
however many cpus and hardware queues exist on the system.
2) scheduling of the such hardware queues being executed by the hardware
(and not by software).

Daves goal: #1; run faster than Usain Bolt.
What we were solving at the time: #2. My view was to solve it with
minimal changes.

#1 and #2 are orthogonal. Yes, there is religion: Dave yours is #1.
Intels is #2; And there are a lot of people in intels camp because
they bill their customers based on qos of resources. The wire being one
such resource.

Example: if you were to use this stuff for virtualization and gave one
customer a cpu and a hardware queue, scheduling is still important. Some
customers pay less (not everyone is Steve Wozniak with his little posse
and can jump queues). 
Therefore your statement that these schemes exist to "enforce fairness
amongst the TX queues" needs to be qualified mon ami;-> The end parts of
Animal Farm come to mind: Some animals have more rights than others;->

[Lets say we forget for a minute about multiegressq nics, we still have
other hardware devices (like hardware L2/L3 switch chips) that do both
multiq and funky prioritization that need to work in the same scheme]

Back to the subject:
I think if one was to use a "qdisc-pass-through" with the what you
have implemented, theres opportunity to let hardware do its scheduling
and meet the goals the intel folks. The filters above just select the
qdisc which is set in hardware.

cheers,
jamal

