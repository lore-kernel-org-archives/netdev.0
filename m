From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH / RFC] net: don't grab a mutex within a timer context in
	gianfar
Date: Fri, 25 Jul 2008 15:02:11 -0400
Message-ID: <0C5F7DBC-2B04-47C0-B14E-D5EEFD344176@freescale.com>
References: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
	<1216681028.7559.993.camel@localhost.localdomain>
	<20080722205911.GA29840@Chamillionaire.breakpoint.cc>
	<20080723200337.GA5122@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Nate Case <ncase@xes-inc.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>, Jeff Garzik <jgarzik@pobox.com>
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080723200337.GA5122@Chamillionaire.breakpoint.cc>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jul 23, 2008, at 16:03, Sebastian Siewior wrote:

> From: Sebastian Siewior <bigeasy@linutronix.de>
>
> I got the following backtrace while network was unavailble:
>
> |NETDEV WATCHDOG: eth0: transmit timed out
> |BUG: sleeping function called from invalid context at /home/bigeasy/ 
> git/linux-2.6-powerpc/kernel/mutex.c:87
> |in_atomic():1, irqs_disabled():0
> |Call Trace:
> |[c0383d90] [c0006dd8] show_stack+0x48/0x184 (unreliable)
> |[c0383db0] [c001e938] __might_sleep+0xe0/0xf4
> |[c0383dc0] [c025a43c] mutex_lock+0x24/0x3c
> |[c0383de0] [c019005c] phy_stop+0x20/0x70
> |[c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
> |[c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
> |[c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144
> |[c0383e30] [c002f93c] run_timer_softirq+0x148/0x1c8
> |[c0383e60] [c002b084] __do_softirq+0x5c/0xc4
> |[c0383e80] [c00046fc] do_softirq+0x3c/0x54
> |[c0383e90] [c002ac60] irq_exit+0x3c/0x5c
> |[c0383ea0] [c000b378] timer_interrupt+0xe0/0xf8
> |[c0383ec0] [c000e5ac] ret_from_except+0x0/0x18
> |[c0383f80] [c000804c] cpu_idle+0xcc/0xdc
> |[c0383fa0] [c025c07c] etext+0x7c/0x90
> |[c0383fc0] [c0338960] start_kernel+0x294/0x2a8
> |[c0383ff0] [c00003dc] skpinv+0x304/0x340
> |------------[ cut here ]------------
>
> The phylock was once a spinlock but got changed into a mutex via
> commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially  
> sleeping]
>
> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
> ---


Looks good to me.  Thanks for taking care of this.

Acked-by: Andy Fleming <afleming@freescale.com>
