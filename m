From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run calls
Date: Thu, 06 Mar 2014 16:06:22 -0500 (EST)
Message-ID: <20140306.160622.59358366688518505.davem@davemloft.net>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed,  5 Mar 2014 00:49:47 +0100

> @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
>  	/* Wait for outstanding qdisc_run calls. */
>  	list_for_each_entry(dev, head, unreg_list)
>  		while (some_qdisc_is_busy(dev))
> -			yield();
> +			msleep(1)
>  }

I don't understand this.

yield() should really _mean_ yield.

The intent of a yield() call, like this one here, is unambiguously
that the current thread cannot do anything until some other thread
gets onto the cpu and makes forward progress.

Therefore it should allow lower priority threads to run, not just
equal or higher priority ones.
