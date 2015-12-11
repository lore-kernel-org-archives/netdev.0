From: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [linux-next] iwl_mvm_get_key_sta_id() suspicious RCU usage
Date: Fri, 11 Dec 2015 22:44:18 +0900
Message-ID: <20151211134418.GA29351@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

linux-next 20151211

[ 6385.246285] ===============================
[ 6385.246288] [ INFO: suspicious RCU usage. ]
[ 6385.246294] 4.4.0-rc4-next-20151211-dbg-00015-g7b65ef3-dirty #302 Not tainted
[ 6385.246296] -------------------------------
[ 6385.246300] drivers/net/wireless/intel/iwlwifi/mvm/sta.c:1226 suspicious rcu_dereference_protected() usage!
[ 6385.246303] 
               other info that might help us debug this:

[ 6385.246308] 
               rcu_scheduler_active = 1, debug_locks = 0
[ 6385.246313] 4 locks held by irq/30-iwlwifi/246:
[ 6385.246316]  #0:  (sync_cmd_lockdep_map){++++..}, at: [<ffffffffa03b34a7>] iwl_pcie_irq_handler+0x5/0xaf4 [iwlwifi]
[ 6385.246341]  #1:  (&(&rxq->lock)->rlock){+.+...}, at: [<ffffffffa03b38c9>] iwl_pcie_irq_handler+0x427/0xaf4 [iwlwifi]
[ 6385.246356]  #2:  (rcu_read_lock){......}, at: [<ffffffffa044c41c>] ieee80211_rx_napi+0x139/0x8f2 [mac80211]
[ 6385.246408]  #3:  (&(&local->rx_path_lock)->rlock){+.-...}, at: [<ffffffffa04498e4>] ieee80211_rx_handlers+0x33/0x21c3 [mac80211]
[ 6385.246448] 
               stack backtrace:
[ 6385.246455] CPU: 0 PID: 246 Comm: irq/30-iwlwifi Not tainted 4.4.0-rc4-next-20151211-dbg-00015-g7b65ef3-dirty #302
[ 6385.246459]  0000000000000000 ffff8800c65678e0 ffffffff811e7d72 ffff88041af55100
[ 6385.246467]  ffff8800c6567910 ffffffff8107dabe 0000000000000000 ffff88041c6d2048
[ 6385.246474]  ffff880416a30a08 ffff88041c6d2048 ffff8800c6567930 ffffffffa04f5106
[ 6385.246480] Call Trace:
[ 6385.246490]  [<ffffffff811e7d72>] dump_stack+0x4b/0x63
[ 6385.246497]  [<ffffffff8107dabe>] lockdep_rcu_suspicious+0xf7/0x100
[ 6385.246517]  [<ffffffffa04f5106>] iwl_mvm_get_key_sta_id.part.0+0x60/0x7f [iwlmvm]
[ 6385.246533]  [<ffffffffa04f6cc5>] iwl_mvm_update_tkip_key+0x43/0x22d [iwlmvm]
[ 6385.246544]  [<ffffffffa04e89ce>] iwl_mvm_mac_update_tkip_key+0x1c/0x1e [iwlmvm]
[ 6385.246578]  [<ffffffffa043fbfa>] ieee80211_tkip_decrypt_data+0x22f/0x44e [mac80211]
[ 6385.246584]  [<ffffffff8108131b>] ? lock_acquire+0x101/0x188
[ 6385.246611]  [<ffffffffa042c7a6>] ieee80211_crypto_tkip_decrypt+0xc8/0x113 [mac80211]
[ 6385.246645]  [<ffffffffa044a319>] ieee80211_rx_handlers+0xa68/0x21c3 [mac80211]
[ 6385.246677]  [<ffffffffa044c293>] ieee80211_prepare_and_rx_handle+0x81f/0x86f [mac80211]
[ 6385.246706]  [<ffffffffa044c41c>] ? ieee80211_rx_napi+0x139/0x8f2 [mac80211]
[ 6385.246711]  [<ffffffff8107cc73>] ? __lock_is_held+0x3c/0x57
[ 6385.246748]  [<ffffffffa044c923>] ieee80211_rx_napi+0x640/0x8f2 [mac80211]
[ 6385.246767]  [<ffffffffa04f232f>] iwl_mvm_rx_rx_mpdu+0x651/0x660 [iwlmvm]
[ 6385.246781]  [<ffffffffa04eccd1>] iwl_mvm_rx+0x58/0x1e6 [iwlmvm]
[ 6385.246793]  [<ffffffffa03b3e02>] iwl_pcie_irq_handler+0x960/0xaf4 [iwlwifi]
[ 6385.246800]  [<ffffffff813bb3a3>] ? __schedule+0x716/0xaf9
[ 6385.246806]  [<ffffffff8108bce4>] ? irq_finalize_oneshot+0xd0/0xd0
[ 6385.246812]  [<ffffffff8108bd01>] irq_thread_fn+0x1d/0x34
[ 6385.246817]  [<ffffffff8108bfaa>] irq_thread+0x10d/0x1b5
[ 6385.246823]  [<ffffffff8108be05>] ? wake_threads_waitq+0x2d/0x2d
[ 6385.246828]  [<ffffffff8108be9d>] ? irq_thread_dtor+0x98/0x98
[ 6385.246833]  [<ffffffff8105c40e>] kthread+0xf8/0x100
[ 6385.246840]  [<ffffffff8105c316>] ? kthread_create_on_node+0x1c7/0x1c7
[ 6385.246847]  [<ffffffff813c05bf>] ret_from_fork+0x3f/0x70
[ 6385.246852]  [<ffffffff8105c316>] ? kthread_create_on_node+0x1c7/0x1c7

	-ss
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
