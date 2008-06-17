From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Tue, 17 Jun 2008 17:40:43 -0500
Message-ID: <1213742443.5771.202.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <20080617152733.7f469f2e@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:39996 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955AbYFQWmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 18:42:13 -0400
In-Reply-To: <20080617152733.7f469f2e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 15:27 -0700, Stephen Hemminger wrote:
> On Tue, 17 Jun 2008 17:08:58 -0500
> Travis Stratman <tstratman@emacinc.com> wrote:
> > 
> > I am working on an application that uses a fairly simple UDP protocol to
> > send data between two embedded devices. I'm noticing an issue with an
> > initial test that was written where datagrams are received but not seen
> > by the recvfrom() call until more data arrives after it.
> > 
> > The target for this code is a board using the Atmel AT91SAM9260 ARM
> > processor. I have tested with 2.6.20 and 2.6.25 on this board.
> > 
> > 
> > When I run the application between two identical devices on a cross-over
> > cable, data is transferred for a few seconds after which everything
> > freezes until I send a ping between the two boards in the background.
> > This forces the communication to start up again for a few seconds before
> > they hang up again.
> > 
> > At first I thought that this was the "rotting packet" case that the NAPI
> > references where an IRQ is missed on Rx, so I rewrote the poll function
> > in the macb driver to try to fix this but I didn't see any noticeable
> > differences.
> > 
> > I would very much appreciate any suggestions that anyone could give to
> > point me in the right direction.
> > 
> > Thanks in advance,
> > 
> > Travis
> 
> I am unfamiliar with interrupts on the ARM. Are IRQ's level or edge triggered?
> NAPI won't work if interrupts are edge-triggered.

Interrupts in this case are set to be level triggered. It has an
interrupt controller that allows them to be configured several ways. The
EMAC driver for the at91sam9260 is in drivers/net/macb.[ch]. Also note
that the 133 MHz x86 that I tested on was an STPC Elite (it also
displayed the same behavior).

Thanks,

Travis


