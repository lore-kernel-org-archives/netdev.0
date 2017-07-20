From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ipv4: initialize fib_trie prior to
 register_netdev_notifier call.
Date: Thu, 20 Jul 2017 15:25:37 -0700 (PDT)
Message-ID: <20170720.152537.415172119439605357.davem@davemloft.net>
References: <20170719224133.34666-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965904AbdGTWZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:25:38 -0400
In-Reply-To: <20170719224133.34666-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 19 Jul 2017 15:41:33 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Net stack initialization currently initializes fib-trie after the
> first call to netdevice_notifier() call. In fact fib_trie initialization
> needs to happen before first rtnl_register(). It does not cause any problem
> since there are no devices UP at this moment, but trying to bring 'lo'
> UP at initialization would make this assumption wrong and exposes the issue.
> 
> Fixes following crash
> 
>  Call Trace:
>   ? alternate_node_alloc+0x76/0xa0
>   fib_table_insert+0x1b7/0x4b0
>   fib_magic.isra.17+0xea/0x120
>   fib_add_ifaddr+0x7b/0x190
>   fib_netdev_event+0xc0/0x130
>   register_netdevice_notifier+0x1c1/0x1d0
>   ip_fib_init+0x72/0x85
>   ip_rt_init+0x187/0x1e9
>   ip_init+0xe/0x1a
>   inet_init+0x171/0x26c
>   ? ipv4_offload_init+0x66/0x66
>   do_one_initcall+0x43/0x160
>   kernel_init_freeable+0x191/0x219
>   ? rest_init+0x80/0x80
>   kernel_init+0xe/0x150
>   ret_from_fork+0x22/0x30
>  Code: f6 46 23 04 74 86 4c 89 f7 e8 ae 45 01 00 49 89 c7 4d 85 ff 0f 85 7b ff ff ff 31 db eb 08 4c 89 ff e8 16 47 01 00 48 8b 44 24 38 <45> 8b 6e 14 4d 63 76 74 48 89 04 24 0f 1f 44 00 00 48 83 c4 08
>  RIP: kmem_cache_alloc+0xcf/0x1c0 RSP: ffff9b1500017c28
>  CR2: 0000000000000014
> 
> Fixes: 7b1a74fdbb9e ("[NETNS]: Refactor fib initialization so it can handle multiple namespaces.")
> Fixes: 7f9b80529b8a ("[IPV4]: fib hash|trie initialization")
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied and queued up for -stable, thanks.
