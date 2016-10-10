From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Tue, 11 Oct 2016 00:30:50 +0900
Message-ID: <20161010153050.GA836@swordfish>
References: <20161010150358.GA514@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161010150358.GA514@swordfish>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc Andy

Andy, can this be related to CONFIG_VMAP_STACK?

On (10/11/16 00:03), Sergey Senozhatsky wrote:
> Hello,
> 
> current -git kills my system. adding
> 
> 	if (!virt_addr_valid(&aad[2])) {
> 		WARN_ON(1);
> 		return -EINVAL;
> 	}
> 
> to ieee80211_aes_ccm_decrypt() given the following backtrace
> 
>  WARNING: CPU: 5 PID: 252 at net/mac80211/aes_ccm.c:77 ieee80211_aes_ccm_decrypt+0xc8/0x197
>  CPU: 5 PID: 252 Comm: irq/29-iwlwifi Tainted: G        W       4.8.0-next-20161010-dbg-00007-g79797e9-dirty #88
>   ffffc90000413638 ffffffff811ff0e3 0000000000000000 0000000000000000
>   ffffc90000413678 ffffffff8103fe91 0000004d000001c8 1ffff920000826d3
>   ffff88040fc526d8 0000000000000008 ffffc90000413978 ffffc9000041397a
>  Call Trace:
>   [<ffffffff811ff0e3>] dump_stack+0x4f/0x65
>   [<ffffffff8103fe91>] __warn+0xc2/0xdd
>   [<ffffffff8103ff1c>] warn_slowpath_null+0x1d/0x1f
>   [<ffffffff8142aaa5>] ieee80211_aes_ccm_decrypt+0xc8/0x197
>   [<ffffffff810ed595>] ? __put_page+0x3c/0x3f
>   [<ffffffff8131fa42>] ? put_page+0x4a/0x62
>   [<ffffffff813218d3>] ? __pskb_pull_tail+0x1e8/0x279
>   [<ffffffff8141a7dc>] ? ccmp_special_blocks.isra.5+0x51/0x12d
>   [<ffffffff8141b226>] ieee80211_crypto_ccmp_decrypt+0x1ba/0x221
>   [<ffffffff81432e80>] ieee80211_rx_handlers+0x52a/0x19c2
>   [<ffffffff81070000>] ? start_dl_timer+0xa8/0xb4
>   [<ffffffff8107462d>] ? put_lock_stats.isra.24+0xe/0x20
>   [<ffffffff8108ebec>] ? del_timer+0x57/0x61
>   [<ffffffff814351a8>] ieee80211_prepare_and_rx_handle+0xcd6/0xd2a
>   [<ffffffff810742a5>] ? local_clock+0x10/0x12
>   [<ffffffff8107642b>] ? __lock_acquire.isra.31+0x202/0x57e
>   [<ffffffff8143207b>] ? rcu_read_unlock+0x23/0x23
>   [<ffffffff81066e77>] ? sched_clock_cpu+0x17/0xc6
>   [<ffffffff814357ab>] ieee80211_rx_napi+0x5af/0x698
>   [<ffffffff810742c0>] ? get_lock_stats+0x19/0x50
>   [<ffffffff8107462d>] ? put_lock_stats.isra.24+0xe/0x20
>   [<ffffffffa023aaa9>] iwl_mvm_rx_rx_mpdu+0x5ab/0x60c [iwlmvm]
>   [<ffffffff810742c0>] ? get_lock_stats+0x19/0x50
>   [<ffffffffa0235c80>] iwl_mvm_rx+0x45/0x69 [iwlmvm]
>   [<ffffffffa01a989e>] iwl_pcie_rx_handle+0x478/0x584 [iwlwifi]
>   [<ffffffffa01aaafd>] iwl_pcie_irq_handler+0x39c/0x52d [iwlwifi]
>   [<ffffffff81080824>] ? irq_finalize_oneshot+0xa7/0xa7
>   [<ffffffff81080841>] irq_thread_fn+0x1d/0x34
>   [<ffffffff81080ab5>] irq_thread+0xe6/0x1bb
>   [<ffffffff8108093a>] ? wake_threads_waitq+0x2c/0x2c
>   [<ffffffff810809cf>] ? irq_thread_dtor+0x95/0x95
>   [<ffffffff81059d79>] kthread+0xc6/0xce
>   [<ffffffff8107462d>] ? put_lock_stats.isra.24+0xe/0x20
>   [<ffffffff81059cb3>] ? __list_del_entry+0x22/0x22
>   [<ffffffff814669d2>] ret_from_fork+0x22/0x30
>  ---[ end trace 94da6d4698b938b2 ]---

	-ss
