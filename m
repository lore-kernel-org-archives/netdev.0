From: David Miller <davem@davemloft.net>
Subject: Re: Generic rx-recycling and emergency skb pool
Date: Fri, 02 Jul 2010 23:46:45 -0700 (PDT)
Message-ID: <20100702.234645.104076220.davem@davemloft.net>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
	<1278138205.2474.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian@breakpoint.cc, netdev@vger.kernel.org, tglx@linutronix.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753721Ab0GCGqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 02:46:32 -0400
In-Reply-To: <1278138205.2474.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Jul 2010 08:23:25 +0200

> Maybe its time to provide new API, so that a driver can build an skb at
> the time RX interrupt is handled, not at the time the rx ring buffer is
> renewed. RX ring should only provide the data part to NIC, and skb
> should be built when NIC delivers the frame, so that we provide to IP
> stack a real hot skb.

Drivers do this already, and in fact I am very sure I'm mentioned this
to you at least other time in the past, and one such driver is NIU :-)

It's trivial to do with devices which work on power-of-2 chopped up
pages.  In fact I'm surprised that RX buffer management scheme is
not more prevalent in network devices.
