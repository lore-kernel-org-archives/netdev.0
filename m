From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deinline netif_tx_stop_all_queues(), remove
 WARN_ON in netif_tx_stop_queue()
Date: Tue, 12 May 2015 23:05:58 -0400 (EDT)
Message-ID: <20150512.230558.437567720437090973.davem@davemloft.net>
References: <1431371873-26969-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, alexander.duyck@gmail.com,
	joe@perches.com, jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431371873-26969-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Mon, 11 May 2015 21:17:53 +0200

> These functions compile to 60 bytes of machine code each.
> With this .config: http://busybox.net/~vda/kernel_config
> there are 617 calls of netif_tx_stop_queue()
> and 49 calls of netif_tx_stop_all_queues() in vmlinux.
> 
> To fix this, remove WARN_ON in netif_tx_stop_queue()
> as suggested by davem, and deinline netif_tx_stop_all_queues().
> 
> Change in code size is about 20k:
> 
>    text      data      bss       dec     hex filename
> 82426986 22255416 20627456 125309858 77813a2 vmlinux.before
> 82406248 22255416 20627456 125289120 777c2a0 vmlinux
> 
> gcc-4.7.2 still creates deinlined version of netif_tx_stop_queue
> sometimes:
> 
> $ nm --size-sort vmlinux | grep netif_tx_stop_queue | wc -l
> 190
> 
> ffffffff81b558a8 <netif_tx_stop_queue>:
> ffffffff81b558a8:       55                      push   %rbp
> ffffffff81b558a9:       48 89 e5                mov    %rsp,%rbp
> ffffffff81b558ac:       f0 80 8f e0 01 00 00    lock orb $0x1,0x1e0(%rdi)
> ffffffff81b558b3:       01
> ffffffff81b558b4:       5d                      pop    %rbp
> ffffffff81b558b5:       c3                      retq
> 
> This needs additional fixing.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Applied, thank you.
