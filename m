From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Mon, 20 Dec 2004 16:15:52 -0800
Message-ID: <20041220161552.2b88aa3d.davem@davemloft.net>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Dec 2004 11:12:23 +1100
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> The problem is that the driver gives up before the switch that the NIC
> is connected to has finished the negotiation phase.
> 
> Here's a simple patch.  I changed the way the loop works too, because
> tg3_readphys() sets *val to 0xffffffff if it fails.

This patch shouldn't be needed.  This waiting loop is just an
optimization in case we can negotiation quickly.

If the loop fails, we just wait for the chip to interrupt us
when the link status changes next (or we notice a link status
change via timer based polling which we use on chips which can't
provide the interrupt based notification properly), at which
time we'll call tg3_setup_copper_phy() from the interrupt handler.

You need to figure out why that isn't working correctly.
