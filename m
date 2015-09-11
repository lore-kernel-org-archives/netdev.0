From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: ali-ircc: Fix deadlock in
 ali_ircc_sir_change_speed()
Date: Fri, 11 Sep 2015 16:18:56 -0700 (PDT)
Message-ID: <20150911.161856.1635045038995107888.davem@davemloft.net>
References: <1442007288-31322-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442007288-31322-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 12 Sep 2015 00:34:48 +0300

> ali_ircc_sir_change_speed() is always called with self->lock held,
> so acquiring the lock inside it leads to unavoidable deadlock.
> 
> Call graph:
> ali_ircc_sir_change_speed() is called from ali_ircc_change_speed()
>   ali_ircc_fir_hard_xmit() under spin_lock_irqsave(&self->lock, flags);
>   ali_ircc_sir_hard_xmit() under spin_lock_irqsave(&self->lock, flags);
>   ali_ircc_net_ioctl() under spin_lock_irqsave(&self->lock, flags);
>   ali_ircc_dma_xmit_complete()
>     ali_ircc_fir_interrupt()
>       ali_ircc_interrupt() under spin_lock(&self->lock);
>   ali_ircc_sir_write_wakeup()
>     ali_ircc_sir_interrupt()
>       ali_ircc_interrupt() under spin_lock(&self->lock);
> 
> The patch removes spin_lock/unlock from ali_ircc_sir_change_speed().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Looks good, applied, thanks.
