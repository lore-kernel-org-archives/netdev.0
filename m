From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] net/am2150: fix nmclan_cs.c shared interrupt handling
Date: Mon, 24 Nov 2014 11:57:55 +0100
Message-ID: <2416727.91yS5gqAdt@wuerfel>
References: <4353896.15JnC91eLO@wuerfel> <20141121.151735.1432199551923486515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	rpao@paonet.org, linux-kernel@vger.kernel.org,
	linux-pcmcia@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141121.151735.1432199551923486515.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 November 2014 15:17:35 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Thu, 20 Nov 2014 16:11:14 +0100
> 
> > A recent patch tried to work around a valid warning for the use of a
> > deprecated interface by blindly changing from the old
> > pcmcia_request_exclusive_irq() interface to pcmcia_request_irq().
> > 
> > This driver has an interrupt handler that is not currently aware
> > of shared interrupts, but can be easily converted to be.
> > At the moment, the driver reads the interrupt status register
> > repeatedly until it contains only zeroes in the interesting bits,
> > and handles each bit individually.
> > 
> > This patch adds the missing part of returning IRQ_NONE in case none
> > of the bits are set to start with, so we can move on to the next
> > interrupt source.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: 5f5316fcd08ef7 ("am2150: Update nmclan_cs.c to use update PCMCIA API")
> > ---
> > I had this patch in my queue of things to submit and noticed that
> > the warning had gone away upstream but my patch was still there.
> > 
> > For all I can tell, the driver is broken without this, although it
> > would rarely be a problem.
> 
> I'm happy for this to go alongside patch #2 via another tree:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

I was hoping you could take at least this one, possibly both.
Since you already had Jeff's patch in it, the first patch now
fixes a (mostly harmless) 3.18 regression, and the second patch
is just a cosmetic cleanup, but there is no longer any dependency
between the two.

It looks like Greg is now handling most of the PCMCIA patches
in the absence of a subsystem maintainer, so I'll send him the
second one for 3.19, let me know if you still want me to send
him the first one too.

	Arnd
