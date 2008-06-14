From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 00:14:28 -0700 (PDT)
Message-ID: <20080614.001428.26649070.davem@davemloft.net>
References: <20080612.211959.52937006.davem@davemloft.net>
	<20080614060320.GA18454@elte.hu>
	<20080614062758.GA23803@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbYFNHO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 03:14:28 -0400
In-Reply-To: <20080614062758.GA23803@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 14 Jun 2008 08:27:58 +0200

> just to clarify the bug pattern: the box was still accessible after the 
> warning. So this is a far less serious problem and i'd suggest we open 
> up a separate regression entry for it and consider the hung-TCP problem 
> closed. (i havent seen the hang in the last week, with either version of 
> the tcp-accept reverts)

It is a warning that just means the transmitted on the network device
stalled for an unusually long period of time.  Is your subnet flooded
when these warnings occur?  Is the remove side system wedged or at a
very high load when the message triggers?

All of these would be useful points of information to determine if
this might be normal or not.

In theory, if the remove port the device is connected to gets
extremely congested, emits a pause frame to your machine, but never
releases that pause, this (new) warning could trigger.

This warning was added by Arjan in 2.6.25 FYI in order to diagnose the
not-normal cases better.
