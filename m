From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pktgen: receive packets and process incoming rate
Date: Tue, 15 Jun 2010 14:59:48 -0700 (PDT)
Message-ID: <20100615.145948.68117816.davem@davemloft.net>
References: <1275483650.2725.173.camel@edumazet-laptop>
	<4C065C7C.4000506@gmail.com>
	<4C10F117.60800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, robert@herjulf.net,
	jens.laas@its.uu.se, voravit@kth.se
To: daniel.turull@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754688Ab0FOV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 17:59:38 -0400
In-Reply-To: <4C10F117.60800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Turull <daniel.turull@gmail.com>
Date: Thu, 10 Jun 2010 16:05:11 +0200

> This patch adds receiver part to pktgen taking advantages of SMP systems
> with multiple rx queues:
> - Creation of new proc file  /proc/net/pktgen/pgrx to control and display the receiver.
> - It uses PER-CPU variable to store the results per each CPU.
> - Results displayed per CPU and aggregated.
> - The packet handler is add in the protocols handlers (dev_add_pack())
> - Available statistics: packets and bytes received, work time and rate
> - Only process pktgen packets
> - It is possible to select the incoming interface 
> - Documentation updated with the new commands to control the receiver part.
> 
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

I completely disagree with this patch on two levels:

1) pktgen is for "generating" packets, not receiving them.
   Trying to put lipstick on a pig is never a good idea.

2) The information it gathers and shows is completely useless.
   What's interesting as "RX work cost" is what happens deep
   down in the netif_receive_skb() code paths, IP input, routing,
   netfilter, whatever... but that is not what this thing is
   measuring at all.

Sorry, I'm not applying this.  You can probably do something more
clever with tracepoints.

