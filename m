From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] [PATCH 2/3] tg3 netpoll hook
Date: Sat, 4 Oct 2003 21:55:12 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005025512.GF13573@waste.org>
References: <20031003014505.GS1897@waste.org> <3F7F857D.5010504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F7F857D.5010504@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2003 at 10:44:13PM -0400, Jeff Garzik wrote:
> Matt Mackall wrote:
> > l-mpm/drivers/net/tg3.c |   16 ++++++++++++++++
> > 1 files changed, 16 insertions(+)
> >
> >diff -puN drivers/net/tg3.c~tg3-poll drivers/net/tg3.c
> >+++ l-mpm/drivers/net/tg3.c	2003-09-25 11:56:37.000000000 -0500
> >@@ -2475,6 +2475,15 @@ static irqreturn_t tg3_interrupt(int irq
> > static int tg3_init_hw(struct tg3 *);
> > static int tg3_halt(struct tg3 *);
> > 
> >+#ifdef HAVE_POLL_CONTROLLER
> >+static void tg3_poll_controller(struct net_device *dev)
> >+{
> >+	disable_irq(dev->irq);
> >+	tg3_interrupt (dev->irq, dev, NULL);
> >+	enable_irq(dev->irq);
> >+}
> >+#endif
> >+
> > static void tg3_reset_task(void *_data)
> > {
> > 	struct tg3 *tp = _data;
> >@@ -7482,6 +7491,10 @@ static struct pci_dev * __devinit tg3_fi
> > 	return peer;
> > }
> > 
> >+#ifdef HAVE_POLL_CONTROLLER
> >+static void tg3_poll_controller(struct net_device *dev);
> >+#endif
> 
> This prototype is pointless.

Indeed. 

Have an opinion on s/->poll_controller/->netpoll/?

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
