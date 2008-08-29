From: David Miller <davem@davemloft.net>
Subject: Re: cpu utilisation improvement when not doing
 netif_tx_{stop,wake}_queue()
Date: Fri, 29 Aug 2008 14:41:44 -0700 (PDT)
Message-ID: <20080829.144144.24237103.davem@davemloft.net>
References: <20080828164638.GA25919@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dale@farnsworth.org, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42097
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750842AbYH2Vlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 17:41:49 -0400
In-Reply-To: <20080828164638.GA25919@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 28 Aug 2008 18:46:38 +0200

> I.e. transmitting wire speed gigabit over a single TCP session takes
> around 90% CPU time (measured with cyclesoak) if I have the TX queue
> flow control enabled, but only 70% if I rip the TX queue flow control
> out.  (This is on a relatively underpowered ARM box.)

I bet TCP is taking over and doing the flow control for us :)

My suspicion is that TCP adjusts to the initial packet drops when the
TX queue overflows for the first time and simply does not transmit
faster than the NIC's TX queue can push things out.

I bet the TX buffer space usage for the socket and the TCP windows
used are smaller too, another huge win and something that also helps
for CPU utilization and cpu cache hit rates.

Unfortunately, for the sake of dumb protocols like UDP, this isn't
something we can do universally.  Although it is very neat!
