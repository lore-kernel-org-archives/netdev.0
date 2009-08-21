From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2/2] drivers/net: fixed drivers that support netpoll
 use ndo_start_xmit()
Date: Fri, 21 Aug 2009 10:26:19 -0500
Message-ID: <1250868379.3937.279.camel@calx>
References: <1250861616.24178.20.camel@dengdd-desktop>
	 <1250861693.24178.22.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Nicolas Pitre <nico@cam.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: DDD <Dongdong.deng@windriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755497AbZHUP1H@vger.kernel.org>
In-Reply-To: <1250861693.24178.22.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-08-21 at 21:34 +0800, DDD wrote:
> The NETPOLL API requires that interrupts remain disabled in
> netpoll_send_skb(). The use of "A functions set" in the NETPOLL API
> callbacks causes the interrupts to get enabled and can lead to kernel
> instability.
> 
> The solution is to use "B functions set" to prevent the irqs from
> getting enabled while in netpoll_send_skb().
> 
> A functions set:
> local_irq_disable()/local_irq_enable()
> spin_lock_irq()/spin_unlock_irq()
> spin_trylock_irq()/spin_unlock_irq()
> 
> B functions set:
> local_irq_save()/local_irq_restore()
> spin_lock_irqsave()/spin_unlock_irqrestore()
> spin_trylock_irqsave()/spin_unlock_irqrestore()
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>

Both of these look good to me, thanks.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux
