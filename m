From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch] tg3 ring buffer allocation error handling
Date: Wed, 14 Apr 2004 16:45:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414214510.GH1175@waste.org>
References: <20040414184642.GZ1175@waste.org> <20040414205959.GA22051@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sven Schuster <schuster.sven@gmx.de>
Content-Disposition: inline
In-Reply-To: <20040414205959.GA22051@zion.homelinux.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 14, 2004 at 10:59:59PM +0200, Sven Schuster wrote:
> On Wed, Apr 14, 2004 at 01:46:42PM -0500, Matt Mackall told us:
> >  	if (tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE) {
> >  		for (i = 0; i < tp->rx_jumbo_pending; i++) {
> >  			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
> > -					     -1, i) < 0)
> > -				break;
> > +					     -1, i) < 0) {
> > +				printk("tg3_alloc_rx_skb %d failed\n", i);
> > +				return -ENOMEM;
> 
> Please correct me if I'm wrong, but shouldn't the buffers from the 
> irst allocation (RXD_OPAQUE_RING_STD) be freed (maybe via 
> tg3_free_rings??) when we get an error here??

The buffers are freed in the module release path, which is invoked
when we return failure here. Without this, we don't notice the
allocation failure and instead blow up when we get traffic.

FYI, I last tested this on a mem=4M box, where it was very obvious
that the 1M of ring buffers weren't leaking.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
