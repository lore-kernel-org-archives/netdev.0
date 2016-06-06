From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 09/12] net: mediatek: increase watchdog_timeo
Date: Mon, 6 Jun 2016 14:21:32 +0200
Message-ID: <20160606122132.GM12165@lunn.ch>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
 <1465108385-38286-10-git-send-email-john@phrozen.org>
 <20160605145632.GI12165@lunn.ch>
 <0da64a49-d100-f83d-e6d3-91b706710660@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sean Wang <keyhaede@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0da64a49-d100-f83d-e6d3-91b706710660@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi Andrew,
> 
> it is waiting for the watchdog to trigger :-) TBH the 1s seems to be too
> short to for the dma ring length to be flushed and i had to pick some
> value and 5 is used most places.
> 
> it really depends on the amount of packets in the queue, their length
> and the mac setting. the timeout needs to be large enough that it would
> not trigger incorrectly even if the mac is on 10mbit half duplex and all
> frames in the queue were maximum size.

So you are saying there is 5 seconds worth of traffic in the transmit ring.

As a general point, not specific to this driver, is that wise? Isn't
that really bad buffer bloat?

I just wondered what happened to cause it to have 5 seconds worth of
traffic in the transmit ring. Did downstream signal a pause?  But i
thought the byte queue limit was designed to prevent a big backlog in
the transmit queue? At 10/Half, is it not reacting fast enough?  Since
it is half duplex, do you have a lot of traffic coming the other way
and something is not being fair at distributing up and down traffic?

I'm just wondering if by increasing the watchdog to 5 seconds, you are
just hiding a problem.

    Andrew
