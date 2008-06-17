From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 02:29:09 -0700 (PDT)
Message-ID: <20080617.022909.173003136.davem@davemloft.net>
References: <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
	<20080617092706.GB20621@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbYFQJ3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 05:29:09 -0400
In-Reply-To: <20080617092706.GB20621@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 17 Jun 2008 11:27:06 +0200

> when i originally reported it i debugged it back to missing e1000 TX 
> completion IRQs. I tried various versions of the driver to figure out 
> whether new workarounds for e1000 cover it but it was fruitless. There 
> is a 1000 msec internal watchdog timer IRQ within e1000 that gets things 
> going if it's stuck.

Then that explains your latency, the chip is getting stuck and
TX interrupts stop, right.

> But the line sch_generic.c:222 problem is new. It could be an 
> escallation of this same problem - not even the hw-internal watchdog 
> timeout fixing up things? So basically two levels of completion failed, 
> the third fallback level (a hard reset of the interface) helped things 
> get going. High score from me for networking layer robustness :-)

I think it is an escallation of the same problem.  My first thought
is that there must have been some change to the reset logic and it
isn't as foolproof as it used to be, especially under load.
