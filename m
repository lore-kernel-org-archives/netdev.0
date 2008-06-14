From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 10:16:56 +0200
Message-ID: <20080614081656.GA27820@elte.hu>
References: <20080612.211959.52937006.davem@davemloft.net> <20080614060320.GA18454@elte.hu> <20080614062758.GA23803@elte.hu> <20080614.001428.26649070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:50426 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120AbYFNIRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 04:17:12 -0400
Content-Disposition: inline
In-Reply-To: <20080614.001428.26649070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> > just to clarify the bug pattern: the box was still accessible after 
> > the warning. So this is a far less serious problem and i'd suggest 
> > we open up a separate regression entry for it and consider the 
> > hung-TCP problem closed. (i havent seen the hang in the last week, 
> > with either version of the tcp-accept reverts)
> 
> It is a warning that just means the transmitted on the network device 
> stalled for an unusually long period of time.  Is your subnet flooded 
> when these warnings occur?  Is the remove side system wedged or at a 
> very high load when the message triggers?

yes, both the network and the testbox is at relatively high load, it's a 
distcc kernel build over the network. Thousands of such iterations were 
done successfully without this warning ever triggering - it triggered 
for the first time in about 10,000 bootups the moment i applied your 
version of the reverts. When i applied the small diff the warning did 
not come back.

> All of these would be useful points of information to determine if 
> this might be normal or not.
> 
> In theory, if the remove port the device is connected to gets 
> extremely congested, emits a pause frame to your machine, but never 
> releases that pause, this (new) warning could trigger.
> 
> This warning was added by Arjan in 2.6.25 FYI in order to diagnose the 
> not-normal cases better.

ok, should we then remove that warning, if it's spurious? kerneloops.org 
has picked up a few other instances of this warning as well:

  http://www.kerneloops.org/searchfile.php?search=net%2Fsched%2Fsch_generic.c&btnG=Filename+Search

	Ingo
