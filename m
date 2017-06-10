From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: caif: Fix a sleep-in-atomic bug in
 cfpkt_create_pfx
Date: Sat, 10 Jun 2017 18:21:29 -0400 (EDT)
Message-ID: <20170610.182129.1342772715077530967.davem@davemloft.net>
References: <1497084579-32434-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497084579-32434-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Sat, 10 Jun 2017 16:49:39 +0800

> The kernel may sleep under a rcu read lock in cfpkt_create_pfx, and the
> function call path is:
> cfcnfg_linkup_rsp (acquire the lock by rcu_read_lock)
>   cfctrl_linkdown_req
>     cfpkt_create
>       cfpkt_create_pfx
>         alloc_skb(GFP_KERNEL) --> may sleep
> cfserl_receive (acquire the lock by rcu_read_lock)
>   cfpkt_split
>     cfpkt_create_pfx
>       alloc_skb(GFP_KERNEL) --> may sleep
> 
> There is "in_interrupt" in cfpkt_create_pfx to decide use "GFP_KERNEL" or
> "GFP_ATOMIC". In this situation, "GFP_KERNEL" is used because the function 
> is called under a rcu read lock, instead in interrupt.
> 
> To fix it, only "GFP_ATOMIC" is used in cfpkt_create_pfx.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied and queued up for -stable.
