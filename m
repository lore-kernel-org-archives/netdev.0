From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] acenic - don't spin in hard_start_xmit when ring fills
Date: Thu, 16 Sep 2004 16:42:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916164206.707204d4@dell_ss3.pdx.osdl.net>
References: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
	<20040916162250.5b7cfa85.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040916162250.5b7cfa85.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 16:22:50 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 16 Sep 2004 16:17:53 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Running performance tests on the acenic, I noticed that the driver
> > spins when the transmit ring gets full.  This might have been okay when
> > CPU's were slower, but it isn't the right thing to do. Better to
> > return TX_BUSY and let network scheduling handle it.
> 
> Acenic does completely lockless processing, are you sure you didn't
> add a race or bug?

NO, the bus just isn't fast enough to keep up with the number of small
packets I am shoving at it.

You got TX_LOCKED and TX_BUSY confused. The problem is drivers that
don't check to see if the last packet sent fills the ring and stop
themselves.

> 	o NETDEV_TX_BUSY Cannot transmit packet, try later 
> 	  Usually a bug, means queue start/stop flow control is broken in
> 	  the driver. Note: the driver must NOT put the skb in its DMA ring.
