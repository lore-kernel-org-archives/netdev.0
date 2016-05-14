From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [linux-next: May 13] intel/iwlwifi/mvm/mvm.h:1069 suspicious
 rcu_dereference_protected() usage
Date: Sun, 15 May 2016 01:31:27 +0900
Message-ID: <20160514163127.GC15615@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

[11455.550649] ===============================
[11455.550652] [ INFO: suspicious RCU usage. ]
[11455.550657] 4.6.0-rc7-next-20160513-dbg-00004-g8de8b92-dirty #655 Not tainted
[11455.550660] -------------------------------
[11455.550664] drivers/net/wireless/intel/iwlwifi/mvm/mvm.h:1069 suspicious rcu_dereference_protected() usage!
[11455.550667] 
               other info that might help us debug this:

[11455.550671] 
               rcu_scheduler_active = 1, debug_locks = 0
[11455.550675] 5 locks held by irq/29-iwlwifi/247:
[11455.550677]  #0:  (sync_cmd_lockdep_map){++++..}, at: [<ffffffffa02283d8>] iwl_pcie_irq_handler+0x0/0x635 [iwlwifi]
[11455.550705]  #1:  (&(&rxq->lock)->rlock){+.+...}, at: [<ffffffffa022709d>] iwl_pcie_rx_handle+0x38/0x5d5 [iwlwifi]
[11455.550725]  #2:  (rcu_read_lock){......}, at: [<ffffffffa033396f>] ieee80211_rx_napi+0x152/0x8e2 [mac80211]
[11455.550768]  #3:  (&(&local->rx_path_lock)->rlock){+.-...}, at: [<ffffffffa03306a1>] ieee80211_rx_handlers+0x2e/0x1fe1 [mac80211]
[11455.550804]  #4:  (rcu_read_lock){......}, at: [<ffffffffa03b49f8>] iwl_mvm_update_tkip_key+0x0/0x162 [iwlmvm]
[11455.550833] 
               stack backtrace:
[11455.550840] CPU: 4 PID: 247 Comm: irq/29-iwlwifi Not tainted 4.6.0-rc7-next-20160513-dbg-00004-g8de8b92-dirty #655
[11455.550844]  0000000000000000 ffff880037ff78e8 ffffffff81187f9c ffff88041b7ea980
[11455.550854]  0000000000000001 ffff880037ff7918 ffffffff8106b836 ffff88041bc0e028
[11455.550863]  0000000000000000 ffff88041d247878 ffff88041bc0e028 ffff880037ff7938
[11455.550872] Call Trace:
[11455.550883]  [<ffffffff81187f9c>] dump_stack+0x68/0x92
[11455.550890]  [<ffffffff8106b836>] lockdep_rcu_suspicious+0xf7/0x100
[11455.550911]  [<ffffffffa03b2321>] iwl_mvm_get_key_sta.part.0+0x5d/0x80 [iwlmvm]
[11455.550930]  [<ffffffffa03b4acb>] iwl_mvm_update_tkip_key+0xd3/0x162 [iwlmvm]
[11455.550945]  [<ffffffffa03a2b60>] iwl_mvm_mac_update_tkip_key+0x17/0x19 [iwlmvm]
[11455.550973]  [<ffffffffa0329646>] ieee80211_tkip_decrypt_data+0x22c/0x24b [mac80211]
[11455.550996]  [<ffffffffa0318bb1>] ieee80211_crypto_tkip_decrypt+0xc5/0x110 [mac80211]
[11455.551026]  [<ffffffffa033102e>] ieee80211_rx_handlers+0x9bb/0x1fe1 [mac80211]
[11455.551035]  [<ffffffff8106b08f>] ? __lock_is_held+0x3c/0x57
[11455.551063]  [<ffffffffa0333773>] ieee80211_prepare_and_rx_handle+0xe89/0xf33 [mac80211]
[11455.551071]  [<ffffffff8119d10f>] ? debug_smp_processor_id+0x17/0x19
[11455.551098]  [<ffffffffa0333cdc>] ieee80211_rx_napi+0x4bf/0x8e2 [mac80211]
[11455.551119]  [<ffffffffa03acd99>] iwl_mvm_rx_rx_mpdu+0x6af/0x754 [iwlmvm]
[11455.551134]  [<ffffffffa03a75be>] iwl_mvm_rx+0x44/0x6d [iwlmvm]
[11455.551147]  [<ffffffffa02274c6>] iwl_pcie_rx_handle+0x461/0x5d5 [iwlwifi]
[11455.551160]  [<ffffffffa022882a>] iwl_pcie_irq_handler+0x452/0x635 [iwlwifi]
[11455.551167]  [<ffffffff8107797d>] ? irq_finalize_oneshot+0xc9/0xc9
[11455.551172]  [<ffffffff81077995>] irq_thread_fn+0x18/0x2f
[11455.551176]  [<ffffffff81077c1d>] irq_thread+0x108/0x1b0
[11455.551183]  [<ffffffff8134338d>] ? __schedule+0x48d/0x58f
[11455.551188]  [<ffffffff81077a82>] ? wake_threads_waitq+0x28/0x28
[11455.551193]  [<ffffffff81077b15>] ? irq_thread_dtor+0x93/0x93
[11455.551198]  [<ffffffff8104e913>] kthread+0xf3/0xfb
[11455.551205]  [<ffffffff81347647>] ? _raw_spin_unlock_irq+0x27/0x45
[11455.551212]  [<ffffffff81347fff>] ret_from_fork+0x1f/0x40
[11455.551217]  [<ffffffff8104e820>] ? kthread_create_on_node+0x1ca/0x1ca

	-ss
