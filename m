From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] drivers/net: fixed drivers that support netpoll use
 ndo_start_xmit()
Date: Fri, 14 Aug 2009 10:33:39 -0500
Message-ID: <1250264019.3807.1301.camel@calx>
References: <1250226751.29401.82.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Ashfield, Bruce" <Bruce.Ashfield@windriver.com>,
	jason.wessel@windriver.com
To: DDD <Dongdong.deng@windriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755804AbZHNPdt@vger.kernel.org>
In-Reply-To: <1250226751.29401.82.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-08-14 at 13:12 +0800, DDD wrote:
> The NETPOLL API requires that interrupts remain disabled in
> netpoll_send_skb(). The use of spin_lock_irq() and spin_unlock_irq()
> in the NETPOLL API callbacks causes the interrupts to get enabled and
> can lead to kernel instability.
> 
> The solution is to use spin_lock_irqsave() and spin_unlock_restore()
> to prevent the irqs from getting enabled while in netpoll_send_skb().
> 
> Call trace:
> netpoll_send_skb()
> {
>    -> local_irq_save(flags)
>      ---> dev->ndo_start_xmit(skb, dev)
>          ---> spin_lock_irq()
>          ---> spin_unlock_irq() *******here would enable the interrupt.
>               ...
>    -> local_irq_restore(flags)
> }
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
> Signed-off-by: Jason Wessel <jason.wessel@windriver.com>
> Acked-by: Bruce Ashfield <bruce.ashfield@windriver.com>

Acked-by: Matt Mackall <mpm@selenic.com>

Perhaps we should also have a WARN_ONCE if start_xmit returns with
interrupts enabled?

-- 
http://selenic.com : development and support for Mercurial and Linux
