From: "Octavian Purdila" <opurdila@ixiacom.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 22:21:02 +0300
Message-ID: <1287084062.1601.36.camel@Nokia-N900-42-11>
Reply-To: <opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <hans.schillstrom@ericsson.com>, <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23918 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752167Ab0JNTU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 15:20:59 -0400
Content-ID: <1287084061.1601.35.camel@Nokia-N900-42-11>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > How can it make a real difference even in this case? We'll obliterate
> > all the entries, and then on subsequent passes we'll find nothing
> > matching that namespace any more.
> > 
> > Show me performance tests that show it makes any difference, please.
> 
> Octavian did you happen to measure the performance difference when you
> added batching of routing table flushes?
> 

Unfortunatelly I dont't have the numbers anymore, but I remember it was noticeable when using a large number of interfaces (10K) - if I remember correctly around 1 second out of 10 for the whole unregister process.

BTW, another bottleneck for mass unregister while interfaces are up is dev_deactivate / dev_close. I experimented with "batchifying" it and for 32K interfaces the time went down from 5mins to 30s.

The patch I have is not pretty, it basically creates another 2 functions for each of dev_close and dev_deactivate for pre and post synchronise_rcu barrier.
