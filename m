From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macmace: disable only the dma interrupt
Date: Sat, 10 Sep 2011 14:30:46 -0400 (EDT)
Message-ID: <20110910.143046.520109083086760748.davem@davemloft.net>
References: <alpine.LNX.2.00.1109110042210.5327@nippy.intranet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1109110042210.5327@nippy.intranet>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Sun, 11 Sep 2011 01:02:16 +1000 (EST)

> Don't disable all interrupts, just disable the relevant one.
> 
> Also move a couple of printk calls outside of local_irq_save/restore.
> 
> Tested on a Quadra 660av.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Using disable_irq() is very expensive, and when done from an interrupt
handler can deadlock especially on SMP (which I understand might not
be relevant here).

I really can't see why you'd do things this way, especially since
interrupt handlers under Linux now unconditionally always run with cpu
interrupts disabled.
