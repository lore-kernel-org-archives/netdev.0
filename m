From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Fri, 30 Apr 2010 16:38:57 -0700 (PDT)
Message-ID: <20100430.163857.180417789.davem@davemloft.net>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	<1272568347.2209.11.camel@edumazet-laptop>
	<20100429214144.GA10663@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, andi@firstfloor.org, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: ak@gargoyle.fritz.box
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759949Ab0D3Xiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:38:52 -0400
In-Reply-To: <20100429214144.GA10663@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@gargoyle.fritz.box>
Date: Thu, 29 Apr 2010 23:41:44 +0200

>     Use io_schedule() in network stack to tell cpuidle governour to guarantee lower latencies
> 
>     XXX: probably too aggressive, some of these sleeps are not under high load.
> 
>     Based on a bug report from Eric Dumazet.
>     
>     Signed-off-by: Andi Kleen <ak@linux.intel.com>

I like this, except that we probably don't want the delayacct_blkio_*() calls
these things do.

Probably the rest of what these things do should remain in the io_schedule*()
functions and the block layer can call it's own versions which add in the
delayacct_blkio_*() bits.

Or, if the delacct stuff is useful for socket I/O too, then it's interfaces
names should have the "blk" stripped from them :-)
