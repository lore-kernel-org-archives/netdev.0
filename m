From: Tom Herbert <therbert@google.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 13:45:37 -0700
Message-ID: <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi> <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hadi@cyberus.ca, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:27961 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910Ab0DNUpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:45:43 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [10.3.21.6])
	by smtp-out.google.com with ESMTP id o3EKjd2U024880
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 22:45:39 +0200
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by hpaq6.eem.corp.google.com with ESMTP id o3EKjAcM020327
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 22:45:38 +0200
Received: by pwj2 with SMTP id 2so556017pwj.31
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 13:45:37 -0700 (PDT)
In-Reply-To: <1271276855.16881.1756.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Only if more than one flow is involved.
>
> And if you have many flows, chance they will spread several queues...
>

But use too many queues and the efficiency of NAPI drops and cost of
device interrupts becomes dominant, so that the overhead from
additional hard interrupts can surpass the overhead of doing RPS and
the IPIs.  I believe we are seeing this is in some of our results
which shows that a combination of multi-queue and RPS can be better
than just multi-queue (see rps changelog).  Again, I'm not claiming
that is generally true, but there are a lot of factors to consider.
