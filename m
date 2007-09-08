From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Fri, 07 Sep 2007 18:01:38 -0700
Message-ID: <3360.1189213298@death>
References: <46E1CA81.6050808@hp.com> <32121.1189207861@death> <46E1E2EE.7080202@hp.com>
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51088 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbXIHBBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 21:01:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8811f9U032367
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 21:01:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8811f5R569124
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 21:01:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8811eot009995
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 21:01:41 -0400
In-reply-to: <46E1E2EE.7080202@hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:
[...]
>> If bonding is the only feeder of the devices, then for a continuous
>> flow of traffic, all the slaves will generally receive packets (from
>> the kernel, for transmission) at pretty much the same rate, and so
>> they won't tend to get ahead or behind.
>
>I could see that if there was just one TCP connection going doing bulk or
>something, but if there were a bulk transmitter coupled with an occasional
>request/response (ie netperf TCP_STREAM and a TCP_RR) i'd think the tx
>rings would no longer remain balanced.

	I'm not sure that would be the case, because even the traffic
"bump" from the TCP_RR would be funneled through the round-robin.  So,
the next packet of the bulk transmit would simply be "pushed back" to
the next available interface.

	Perhaps varying packet sizes would throw things out of whack, if
the small ones happened to line up all one one interface (regardless of
the other traffic).

	A PAUSE frame to one interface would almost certainly get things
out of whack, but I don't know how long it would stay out of whack (or,
really, how likely getting a PAUSE is).  Probably just as long as all of
the slaves are running at full speed.

>> 	I haven't investigated into this deeply for a few years, but
>> this is my recollection of what happened with the tests I did then.  I
>> did testing with multiple 100Mb devices feeding either other sets of
>> 100Mb devices or single gigabit devices.  I'm willing to believe that
>> things have changed, and an N feeding into one configuration can
>> reorder, but I haven't seen it (or really looked for it; balance-rr
>> isn't much the rage these days).
>
>Are you OK with that block of text simply being yanked?

	Mmm... I'm an easy sell for a "usually" or other suitable caveat
added in strategic places (avoiding absolute statements and all that).
The text does reflect the results of experiments I ran at the time, so
I'm reluctant to toss it wholesale simply because we speculate over how
it might not be accurate.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
