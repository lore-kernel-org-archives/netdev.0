From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enic: Fix a sleep-in-atomic bug
Date: Wed, 31 May 2017 14:37:38 -0400 (EDT)
Message-ID: <20170531.143738.91013741875059886.davem@davemloft.net>
References: <1496198089-1596-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, _govind@gmx.com, neepatel@cisco.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496198089-1596-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Wed, 31 May 2017 10:34:49 +0800

> The driver may sleep under a spin lock in some function call paths.
> The 1st function call path is:
> enic_reset (acquire the lock by spin_lock)
>   enic_stop
>     enic_synchronize_irqs
>       synchronize_irq --> may sleep
> The 2nd function call path is:
> enic_reset (acquire the lock by spin_lock)
>   enic_dev_soft_reset
>     enic_dev_wait
>       schedule_timeout_uninterruptible --> may sleep
> The 3rd function call path is:
> enic_reset (acquire the lock by spin_lock)
>   enic_open
>     enic_request_intr
>       enic_set_rx_cpu_rmap
>         enic_free_rx_cpu_rmap
>           free_irq_cpu_rmap --> may sleep
> 
> To fix it, the "spin_lock" and "spin_unlock" are removed in enic_reset.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

That's not necessarily safe at all, the lock is probably needed for
synchronization.
