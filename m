From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Wed, 06 May 2009 09:46:33 +0200
Message-ID: <1241595993.5172.4.camel@localhost.localdomain>
References: <20090505.115819.84151021.davem@davemloft.net>
	 <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	 <9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
	 <20090505.143529.148721206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hawk@diku.dk, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:60300 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbZEFHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 03:46:34 -0400
In-Reply-To: <20090505.143529.148721206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-05 at 14:35 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 5 May 2009 14:32:04 -0700
> 
> > the manual[1] for the hardware says:
> > RNBC:
> > This register counts the number of times that frames were received
> > when there were no available buffers in host memory to store those
> > frames (receive descriptor head and tail pointers were equal). The
> > packet is still received if there is space in the FIFO. This register
> > only increments if receives are enabled. This register does not
> > increment when flow control packets are received.
> > 
> > The critical bit "The packet is still received if there is space in
> > the FIFO" (AND a host memory buffer becomes available) So the reason
> > we don't want to put it in the net_stats stats for drops is that the
> > packet
> > *wasn't* necessarily dropped.
> > 
> > The rx_missed errors is for packets that were definitely dropped, and
> > is already stored in the net_stats structure.
> 
> While not an "rx_missed" because we do eventually take the
> packet, conceptually it is a "fifo overflow" in the sense
> that we exceeded available receive resources at the time that
> the packet arrived.

Yes, with this argumentation, the MPC should then be kept as "rx_missed"
packets.  And the RNBC stored as "rx_fifo_errors" as its an overflow
indication, not a number of packets dropped.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

