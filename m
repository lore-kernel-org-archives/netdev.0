From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix an use-after-free issue for nlk groups
Date: Wed, 06 Sep 2017 21:24:19 -0700 (PDT)
Message-ID: <20170906.212419.1982531430917223449.davem@davemloft.net>
References: <1217baf9faf9d034ba8224cb6362b822c51a0eae.1504669632.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIGEYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:24:21 -0400
In-Reply-To: <1217baf9faf9d034ba8224cb6362b822c51a0eae.1504669632.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed,  6 Sep 2017 11:47:12 +0800

> ChunYu found a netlink use-after-free issue by syzkaller:
> 
> [28448.842981] BUG: KASAN: use-after-free in __nla_put+0x37/0x40 at addr ffff8807185e2378
> [28448.969918] Call Trace:
> [...]
> [28449.117207]  __nla_put+0x37/0x40
> [28449.132027]  nla_put+0xf5/0x130
> [28449.146261]  sk_diag_fill.isra.4.constprop.5+0x5a0/0x750 [netlink_diag]
> [28449.176608]  __netlink_diag_dump+0x25a/0x700 [netlink_diag]
> [28449.202215]  netlink_diag_dump+0x176/0x240 [netlink_diag]
> [28449.226834]  netlink_dump+0x488/0xbb0
> [28449.298014]  __netlink_dump_start+0x4e8/0x760
> [28449.317924]  netlink_diag_handler_dump+0x261/0x340 [netlink_diag]
> [28449.413414]  sock_diag_rcv_msg+0x207/0x390
> [28449.432409]  netlink_rcv_skb+0x149/0x380
> [28449.467647]  sock_diag_rcv+0x2d/0x40
> [28449.484362]  netlink_unicast+0x562/0x7b0
> [28449.564790]  netlink_sendmsg+0xaa8/0xe60
> [28449.661510]  sock_sendmsg+0xcf/0x110
> [28449.865631]  __sys_sendmsg+0xf3/0x240
> [28450.000964]  SyS_sendmsg+0x32/0x50
> [28450.016969]  do_syscall_64+0x25c/0x6c0
> [28450.154439]  entry_SYSCALL64_slow_path+0x25/0x25
> 
> It was caused by no protection between nlk groups' free in netlink_release
> and nlk groups' accessing in sk_diag_dump_groups. The similar issue also
> exists in netlink_seq_show().
> 
> This patch is to defer nlk groups' free in deferred_put_nlk_sk.
> 
> Reported-by: ChunYu Wang <chunwang@redhat.com>
> Acked-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
