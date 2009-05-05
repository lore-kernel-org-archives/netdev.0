From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Tue, 05 May 2009 14:35:29 -0700 (PDT)
Message-ID: <20090505.143529.148721206.davem@davemloft.net>
References: <20090505.115819.84151021.davem@davemloft.net>
	<Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	<9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, hawk@comx.dk, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752996AbZEEVfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 17:35:34 -0400
In-Reply-To: <9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 5 May 2009 14:32:04 -0700

> the manual[1] for the hardware says:
> RNBC:
> This register counts the number of times that frames were received
> when there were no available buffers in host memory to store those
> frames (receive descriptor head and tail pointers were equal). The
> packet is still received if there is space in the FIFO. This register
> only increments if receives are enabled. This register does not
> increment when flow control packets are received.
> 
> The critical bit "The packet is still received if there is space in
> the FIFO" (AND a host memory buffer becomes available) So the reason
> we don't want to put it in the net_stats stats for drops is that the
> packet
> *wasn't* necessarily dropped.
> 
> The rx_missed errors is for packets that were definitely dropped, and
> is already stored in the net_stats structure.

While not an "rx_missed" because we do eventually take the
packet, conceptually it is a "fifo overflow" in the sense
that we exceeded available receive resources at the time that
the packet arrived.
