From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 22:39:25 -0800 (PST)
Message-ID: <20080108.223925.105105455.davem@davemloft.net>
References: <4783AA29.3080406@psc.edu>
	<20080108.144456.173014334.davem@davemloft.net>
	<p73sl17pwfy.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751693AbYAIGj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:39:26 -0500
In-Reply-To: <p73sl17pwfy.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 09 Jan 2008 03:25:05 +0100

> David Miller <davem@davemloft.net> writes:
> >
> > The big problem is that recovery from even a single packet loss in a
> > window makes us run kfree_skb() for a all the packets in a full
> > window's worth of data when recovery completes.
> 
> Why exactly is it a problem to free them all at once? Are you worried
> about kernel preemption latencies?

If the cpu is there spinning freeing up 500,000 SKBs, it isn't
processing RX packets.

It adds severe spikes in CPU utilization that are even moderate
line rates begins to affect RTTs.

Or do you think it's OK to process 500,000 SKBs while locked
in a software interrupt.

Perhaps you have another broken awk script to prove this :-)
