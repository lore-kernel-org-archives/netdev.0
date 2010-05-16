From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/5] generic rx recycling
Date: Sat, 15 May 2010 23:32:45 -0700 (PDT)
Message-ID: <20100515.233245.90775757.davem@davemloft.net>
References: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752333Ab0EPGci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:32:38 -0400
In-Reply-To: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Wed,  5 May 2010 16:47:45 +0200

> This series merges the rx recycling code trying to come up with generic
> code. Recycling skbs from the tx path for incomming rx skips the memory
> allocater and improves latency during memory pressure.
> This is now used by just by just four drivers in the tree which were doing
> this on their own.

You're adding new unnecessary SMP locking to all of these drivers.

In the gianfar original code the recycle queue is accessed lockless
using __skb_dequeue() et al.  But you're using the skb_dequeue()
interface in the generic version which takes the SKB queue lock
which is absolutely unnecessary where these drivers make these
calls since they already need to have their chip RX path locked
already.
