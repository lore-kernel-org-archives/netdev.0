From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Tue, 21 Apr 2009 11:52:07 -0700
Message-ID: <65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	 <87eivnpqde.fsf@basil.nowhere.org>
	 <65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
	 <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:54130 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758048AbZDUSwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 14:52:13 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n3LIqAAU017307
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 11:52:10 -0700
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by spaceape9.eur.corp.google.com with ESMTP id n3LIq7Vl021099
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 11:52:08 -0700
Received: by rv-out-0708.google.com with SMTP id b17so1152808rvf.54
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 11:52:07 -0700 (PDT)
In-Reply-To: <20090421084636.198b181e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Hello Tom
>>
>> I was thinking about your patch (and David's one), and thought it could be
>> possible to spread packets to other cpus only if current one is under stress.
>>
>> A posssible metric would be to test if softirq is handled by ksoftirqd
>> (stress situation) or not.
>>
>> Under moderate load, we could have one active cpu (and fewer cache line
>> transferts), keeping good latencies.
>>
>> I tried alternative approach to solve the Multicast problem raised some time ago,
>> but still have one cpu handling one device. Only wakeups were defered to a
>> workqueue (and possibly another cpu) if running from ksoftirq only.
>> Patch not yet ready for review, but based on a previous patch that was more
>> intrusive (touching kernel/softirq.c)
>>
>> Under stress, your idea permits to use more cpus for a fast NIC and get better
>> throughput. Its more generic.
>
> I would like to see some way to have multiple CPU's pulling packets and adapting
> the number of CPU's being used based on load. Basically, turn all device is into
> receive multiqueue. The mapping could be adjusted by user level (see irqbalancer).
>

That is possible and don't think the design of our patch would
preclude it, but I am worried that each time the mapping from a
connection to a CPU changes this could cause of out of order packets.
I suppose this is similar problem to changing the RSS hash mappings in
a device.

Tom
