From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Wed, 10 Jun 2009 01:23:42 -0700 (PDT)
Message-ID: <20090610.012342.121254416.davem@davemloft.net>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44578
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754559AbZFJIXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:23:40 -0400
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 3 May 2009 21:03:01 -0700

> This is an update of the receive packet steering patch (RPS) based on received
> comments (thanks for all the comments).  Improvements are:
> 
> 1) Removed config option for the feature.
> 2) Made scheduling of backlog NAPI devices between CPUs lockless and much
> simpler.
> 3) Added new softirq to do defer sending IPIs for coalescing.
> 4) Imported hash from simple_rx_hash.  Eliminates modulo operation to convert
> hash to index.
> 5) If no cpu is found for packet steering, then netif_receive_skb processes
> packet inline as before without queueing.  In paritcular if RPS is not
> configured on a device the receive path is unchanged from current for
> NAPI devices (one additional conditional).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Just to keep this topic alive, I want to mention two things:

1) Just the other day support for the IXGBE "Flow Director" was
   added to net-next-2.6, it basically does flow steering in
   hardware.  It remembers where the last TX for a flow was
   made, and steers RX traffic there.

   It's essentially a HW implementation of what we're proposing
   here to do in software.

2) I'm steadily still trying to get struct sk_buff to the point
   where we can replace the list handling implementation with a
   standard "struct list_head" and thus union that with a
   "struct call_single_data" so we can use remote cpu soft-irqs
   for software packet flow steering.
