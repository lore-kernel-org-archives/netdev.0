From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers/net: fixed drivers that support netpoll
 use ndo_start_xmit()
Date: Sun, 23 Aug 2009 19:50:07 -0700 (PDT)
Message-ID: <20090823.195007.192261442.davem@davemloft.net>
References: <1250861616.24178.20.camel@dengdd-desktop>
	<1250861693.24178.22.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, nico@cam.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jason.wessel@windriver.com
To: Dongdong.deng@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbZHXCty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 22:49:54 -0400
In-Reply-To: <1250861693.24178.22.camel@dengdd-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: DDD <Dongdong.deng@windriver.com>
Date: Fri, 21 Aug 2009 21:34:53 +0800

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

Applied.
