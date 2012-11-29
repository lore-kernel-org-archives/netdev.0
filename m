From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] solos-pci: don't call vcc->pop() after pclose()
Date: Thu, 29 Nov 2012 09:41:04 -0500
Message-ID: <20121129094104.61c9f19f@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<1354141115.21562.101.camel@shinybook.infradead.org>
	<20121129105715.GA10226@shrek.podlesie.net>
	<1354190143.21562.145.camel@shinybook.infradead.org>
	<20121129124344.GA7704@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121129124344.GA7704@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Nov 2012 13:43:44 +0100
Krzysztof Mazur <krzysiek@podlesie.net> wrote:

> Removing packets from tx_queue is not needed. We can transmit packets
> also after close. We just can't call vcc->pop() after close,
> so we can just set SKB_CB(skb)->vcc of such packets to NULL so fpga_tx()
> won't call vcc->pop().

i dont think you can transmit packets after close().  you can transmit
packets during close() though.  if you transmit after close that means
that you are using the vpi/vci pair that the atm stack thinks is no
longer in use.  additionally after close(), the hardware should be in a
state such that you cannot transmit or receive on the vpi/vci that has
been closed.

close() needs to make sure that any pending tx packets are sent or
otherwise disposed of (like turning off the transmit segmentation
engine, clearing the packets, or whatever).  any partially reassembled
pdu's also need to be cleared as well.
