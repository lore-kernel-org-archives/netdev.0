From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run calls
Date: Fri, 07 Mar 2014 05:26:37 +0100
Message-ID: <1394166397.5056.40.camel@marge.simpson.net>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
	 <20140306.160622.59358366688518505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306.160622.59358366688518505.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote: 
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Wed,  5 Mar 2014 00:49:47 +0100
> 
> > @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
> >  	/* Wait for outstanding qdisc_run calls. */
> >  	list_for_each_entry(dev, head, unreg_list)
> >  		while (some_qdisc_is_busy(dev))
> > -			yield();
> > +			msleep(1)
> >  }
> 
> I don't understand this.
> 
> yield() should really _mean_ yield.

It does, but yield() semantics make it useless for what you want to do..
and pretty much undefined for anything other than SCHED_FIFO.  If you
really want to give up the CPU to any old body, you have to sleep.

-Mike
