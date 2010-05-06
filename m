From: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org
Subject: 2.6.34-rc5-mmotm0428 - 2 RCU whinges in mac80211
Date: Thu, 06 May 2010 13:35:13 -0400
Message-ID: <5820.1273167313@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273167313_4094P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1273167313_4094P
Content-Type: text/plain; charset=us-ascii

Spotted these in my dmesg, hopefully somebody is interested...

[   54.076863] wlan0: deauthenticating from 00:11:20:a4:4c:11 by local choice (reason=3)
[   54.080580] 
[   54.080581] ===================================================
[   54.080584] [ INFO: suspicious rcu_dereference_check() usage. ]
[   54.080586] ---------------------------------------------------
[   54.080589] net/mac80211/sta_info.c:858 invoked rcu_dereference_check() without protection!
[   54.080591] 
[   54.080591] other info that might help us debug this:
[   54.080592] 
[   54.080594] 
[   54.080595] rcu_scheduler_active = 1, debug_locks = 1
[   54.080597] no locks held by hald/3362.
[   54.080599] 
[   54.080599] stack backtrace:
[   54.080602] Pid: 3362, comm: hald Not tainted 2.6.34-rc5-mmotm0428 #1
[   54.080604] Call Trace:
[   54.080607]  <IRQ>  [<ffffffff81064eb9>] lockdep_rcu_dereference+0x9d/0xa5
[   54.080619]  [<ffffffff815649f9>] ieee80211_find_sta_by_hw+0x46/0x10f
[   54.080623]  [<ffffffff81564ad9>] ieee80211_find_sta+0x17/0x19
[   54.080628]  [<ffffffff8136e1ee>] iwlagn_tx_queue_reclaim+0xe7/0x1bd
[   54.080632]  [<ffffffff81371da3>] iwlagn_rx_reply_tx+0x4e9/0x5a6
[   54.080638]  [<ffffffff8136501f>] iwl_rx_handle+0x268/0x3fe
[   54.080642]  [<ffffffff813664ea>] iwl_irq_tasklet+0x2d3/0x3e4
[   54.080647]  [<ffffffff8103e337>] tasklet_action+0x79/0xd7
[   54.080651]  [<ffffffff8103fd54>] __do_softirq+0x15a/0x2a2
[   54.080656]  [<ffffffff8100358c>] call_softirq+0x1c/0x34
[   54.080659]  [<ffffffff81004ad8>] do_softirq+0x44/0xf0
[   54.080663]  [<ffffffff8103f3ba>] irq_exit+0x4a/0xb3
[   54.080667]  [<ffffffff81004211>] do_IRQ+0xa7/0xbe
[   54.080671]  [<ffffffff8159cd93>] ret_from_intr+0x0/0xf
[   54.080673]  <EOI> 
[   54.114898] wlan0: authenticate with 00:11:20:a4:4c:11 (try 1)
[   54.122103] wlan0: authenticated
[   54.122472] wlan0: associate with 00:11:20:a4:4c:11 (try 1)
[   54.128267] wlan0: RX AssocResp from 00:11:20:a4:4c:11 (capab=0x31 status=0 aid=10)
[   54.128271] wlan0: associated
[   54.132990] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   54.133333] cfg80211: Calling CRDA for country: US
[   54.135752] 
[   54.135753] ===================================================
[   54.135756] [ INFO: suspicious rcu_dereference_check() usage. ]
[   54.135758] ---------------------------------------------------
[   54.135760] net/mac80211/sta_info.c:858 invoked rcu_dereference_check() without protection!
[   54.135763] 
[   54.135763] other info that might help us debug this:
[   54.135764] 
[   54.135766] 
[   54.135767] rcu_scheduler_active = 1, debug_locks = 1
[   54.135769] 1 lock held by udevd/2933:
[   54.135771]  #0:  (policy_rwlock){.+.+..}, at: [<ffffffff811d4f60>] security_compute_av+0x29/0x259
[   54.135781] 
[   54.135782] stack backtrace:
[   54.135785] Pid: 2933, comm: udevd Not tainted 2.6.34-rc5-mmotm0428 #1
[   54.135787] Call Trace:
[   54.135790]  <IRQ>  [<ffffffff81064eb9>] lockdep_rcu_dereference+0x9d/0xa5
[   54.135800]  [<ffffffff81564a49>] ieee80211_find_sta_by_hw+0x96/0x10f
[   54.135804]  [<ffffffff81564ad9>] ieee80211_find_sta+0x17/0x19
[   54.135809]  [<ffffffff8136e1ee>] iwlagn_tx_queue_reclaim+0xe7/0x1bd
[   54.135813]  [<ffffffff81371da3>] iwlagn_rx_reply_tx+0x4e9/0x5a6
[   54.135819]  [<ffffffff8136501f>] iwl_rx_handle+0x268/0x3fe
[   54.135823]  [<ffffffff813664ea>] iwl_irq_tasklet+0x2d3/0x3e4
[   54.135828]  [<ffffffff8103e337>] tasklet_action+0x79/0xd7
[   54.135832]  [<ffffffff8103fd54>] __do_softirq+0x15a/0x2a2
[   54.135837]  [<ffffffff8100358c>] call_softirq+0x1c/0x34
[   54.135841]  [<ffffffff81004ad8>] do_softirq+0x44/0xf0
[   54.135844]  [<ffffffff8103f3ba>] irq_exit+0x4a/0xb3
[   54.135847]  [<ffffffff81004211>] do_IRQ+0xa7/0xbe
[   54.135852]  [<ffffffff8159cd93>] ret_from_intr+0x0/0xf
[   54.135854]  <EOI>  [<ffffffff811ce48b>] ? avtab_search_node+0x6c/0x7b
[   54.135862]  [<ffffffff811d4cdb>] context_struct_compute_av+0x136/0x271
[   54.135867]  [<ffffffff811d506b>] security_compute_av+0x134/0x259
[   54.135872]  [<ffffffff811c2560>] avc_has_perm_noaudit+0x22e/0x537
[   54.135876]  [<ffffffff811c289f>] avc_has_perm+0x36/0x69
[   54.135880]  [<ffffffff810c52cd>] ? __do_fault+0x254/0x3f1
[   54.135885]  [<ffffffff811c4bca>] current_has_perm+0x3a/0x3f
[   54.135888]  [<ffffffff811c4c7d>] selinux_task_create+0x17/0x19
[   54.135893]  [<ffffffff811beced>] security_task_create+0x11/0x13
[   54.135898]  [<ffffffff81036dae>] copy_process+0x8d/0x11ed
[   54.135901]  [<ffffffff810c5434>] ? __do_fault+0x3bb/0x3f1
[   54.135905]  [<ffffffff8107c26b>] ? rcu_read_lock+0x0/0x35
[   54.135909]  [<ffffffff810380b2>] do_fork+0x1a4/0x3b5
[   54.135913]  [<ffffffff8107c2c1>] ? rcu_read_unlock+0x21/0x23
[   54.135917]  [<ffffffff8107dc56>] ? audit_filter_syscall+0xb4/0xc8
[   54.135921]  [<ffffffff81059044>] ? up_read+0x1e/0x36
[   54.135924]  [<ffffffff8105d760>] ? current_kernel_time+0x28/0x50
[   54.135929]  [<ffffffff81009705>] sys_clone+0x23/0x25
[   54.135933]  [<ffffffff810029d3>] stub_clone+0x13/0x20
[   54.135936]  [<ffffffff8100266b>] ? system_call_fastpath+0x16/0x1b



--==_Exmh_1273167313_4094P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL4v3RcC3lWbTT17ARAshDAKCFiBojOS41qx3hPXB++zZVAn5TvwCg77HD
H0rtTAidfFc1nQ6+QzyL370=
=hvy8
-----END PGP SIGNATURE-----

--==_Exmh_1273167313_4094P--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
