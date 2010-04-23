From: Miles Lane <miles.lane@gmail.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
	rcu_dereference_check() usage
Date: Fri, 23 Apr 2010 08:50:59 -0400
Message-ID: <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
References: <20100419230136.GA16856@linux.vnet.ibm.com>
	 <20100420030452.GB2905@linux.vnet.ibm.com>
	 <4BCD646B.1080206@cn.fujitsu.com>
	 <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
	 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
	 <20100420135227.GC2628@linux.vnet.ibm.com>
	 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	 <20100421213543.GO2563@linux.vnet.ibm.com>
	 <20100422145640.GB3228@redhat.com>
	 <20100422160144.GC2524@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100422160144.GC2524@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,
There has been a bit of back and forth, and I am not sure what patches
I should test now.
Could you send me a bundle of whatever needs testing now?

I currently have a build of 2.6.34-rc5-git3 with the same patch I
tested before applied.
I notice a few minor differences in the warnings given.  I suspect
these do not indicate
new issues, since the trace from <IRQ> through <EOI> is the same as before.

[   60.174809] [ INFO: suspicious rcu_dereference_check() usage. ]
[   60.174812] ---------------------------------------------------
[   60.174816] net/mac80211/sta_info.c:886 invoked
rcu_dereference_check() without protection!
[   60.174820]
[   60.174821] other info that might help us debug this:
[   60.174822]
[   60.174825]
[   60.174826] rcu_scheduler_active = 1, debug_locks = 1
[   60.174829] no locks held by wpa_supplicant/3973.
[   60.174832]
[   60.174833] stack backtrace:
[   60.174838] Pid: 3973, comm: wpa_supplicant Not tainted 2.6.34-rc5-git3 #19
[   60.174841] Call Trace:
[   60.174844]  <IRQ>  [<ffffffff81067faa>] lockdep_rcu_dereference+0x9d/0xa5
[   60.174873]  [<ffffffffa014e9ae>]
ieee80211_find_sta_by_hw+0x46/0x10f [mac80211]
[   60.174886]  [<ffffffffa014ea8e>] ieee80211_find_sta+0x17/0x19 [mac80211]
[   60.174902]  [<ffffffffa01a60f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [iwlcore]
[   60.174909]  [<ffffffff81068417>] ? mark_lock+0x2d/0x235
[   60.174920]  [<ffffffffa01d5f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [iwlagn]
[   60.174927]  [<ffffffff8120a2d3>] ? is_swiotlb_buffer+0x2e/0x3b
[   60.174936]  [<ffffffffa01cebf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
[   60.174943]  [<ffffffff810688f0>] ? trace_hardirqs_on_caller+0xfa/0x13f
[   60.174952]  [<ffffffffa01cf3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlagn]
[   60.174959]  [<ffffffff810411df>] tasklet_action+0xa7/0x10f
[   60.174965]  [<ffffffff810421f1>] __do_softirq+0x144/0x252
[   60.174972]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
[   60.174977]  [<ffffffff810050e4>] do_softirq+0x38/0x80
[   60.174982]  [<ffffffff81041cbe>] irq_exit+0x45/0x94
[   60.174987]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
[   60.174994]  [<ffffffff813cfb13>] ret_from_intr+0x0/0xf
[   60.174997]  <EOI>  [<ffffffff810e5114>] ? kmem_cache_alloc+0xa9/0x15f
[   60.175010]  [<ffffffff81342182>] ? __alloc_skb+0x3d/0x155
[   60.175016]  [<ffffffff81342182>] __alloc_skb+0x3d/0x155
[   60.175023]  [<ffffffff8133d237>] sock_alloc_send_pskb+0xc0/0x2e5
[   60.175030]  [<ffffffff8133d46c>] sock_alloc_send_skb+0x10/0x12
[   60.175036]  [<ffffffff813b1ab5>] unix_stream_sendmsg+0x117/0x2e2
[   60.175044]  [<ffffffff811bdca8>] ? avc_has_perm+0x57/0x69
[   60.175050]  [<ffffffff8133b892>] ? sock_aio_write+0x0/0xcf
[   60.175056]  [<ffffffff813392c2>] __sock_sendmsg+0x59/0x64
[   60.175062]  [<ffffffff8133b94d>] sock_aio_write+0xbb/0xcf
[   60.175069]  [<ffffffff810e98b1>] do_sync_readv_writev+0xbc/0xfb
[   60.175077]  [<ffffffff811c1726>] ? selinux_file_permission+0xa2/0xaf
[   60.175082]  [<ffffffff810e9638>] ? copy_from_user+0x2a/0x2c
[   60.175089]  [<ffffffff811baf85>] ? security_file_permission+0x11/0x13
[   60.175095]  [<ffffffff810ea64e>] do_readv_writev+0xa2/0x122
[   60.175101]  [<ffffffff810ead3b>] ? fcheck_files+0x8f/0xc9
[   60.175107]  [<ffffffff810ea70c>] vfs_writev+0x3e/0x49
[   60.175113]  [<ffffffff810ea7f2>] sys_writev+0x45/0x8e
[   60.175119]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

[   60.223213] [ INFO: suspicious rcu_dereference_check() usage. ]
[   60.223216] ---------------------------------------------------
[   60.223221] net/mac80211/sta_info.c:886 invoked
rcu_dereference_check() without protection!
[   60.223224]
[   60.223225] other info that might help us debug this:
[   60.223227]
[   60.223230]
[   60.223230] rcu_scheduler_active = 1, debug_locks = 1
[   60.223234] no locks held by udisks-daemon/4398.
[   60.223236]
[   60.223237] stack backtrace:
[   60.223242] Pid: 4398, comm: udisks-daemon Not tainted 2.6.34-rc5-git3 #19
[   60.223245] Call Trace:
[   60.223249]  <IRQ>  [<ffffffff81067faa>] lockdep_rcu_dereference+0x9d/0xa5
[   60.223275]  [<ffffffffa014e9fe>]
ieee80211_find_sta_by_hw+0x96/0x10f [mac80211]
[   60.223288]  [<ffffffffa014ea8e>] ieee80211_find_sta+0x17/0x19 [mac80211]
[   60.223304]  [<ffffffffa01a60f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [iwlcore]
[   60.223310]  [<ffffffff81068417>] ? mark_lock+0x2d/0x235
[   60.223321]  [<ffffffffa01d5f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [iwlagn]
[   60.223329]  [<ffffffff8120a2d3>] ? is_swiotlb_buffer+0x2e/0x3b
[   60.223338]  [<ffffffffa01cebf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
[   60.223344]  [<ffffffff810688f0>] ? trace_hardirqs_on_caller+0xfa/0x13f
[   60.223353]  [<ffffffffa01cf3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlagn]
[   60.223360]  [<ffffffff810411df>] tasklet_action+0xa7/0x10f
[   60.223367]  [<ffffffff810421f1>] __do_softirq+0x144/0x252
[   60.223374]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
[   60.223379]  [<ffffffff810050e4>] do_softirq+0x38/0x80
[   60.223384]  [<ffffffff81041cbe>] irq_exit+0x45/0x94
[   60.223389]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
[   60.223396]  [<ffffffff813cfb13>] ret_from_intr+0x0/0xf
[   60.223399]  <EOI>  [<ffffffff810e34f1>] ? kmem_cache_free+0xb0/0x134
[   60.223412]  [<ffffffff810f391a>] ? putname+0x2d/0x36
[   60.223417]  [<ffffffff810f391a>] putname+0x2d/0x36
[   60.223423]  [<ffffffff810f5536>] user_path_at+0x5f/0x8e
[   60.223429]  [<ffffffff81068671>] ? mark_held_locks+0x52/0x70
[   60.223435]  [<ffffffff810e34ee>] ? kmem_cache_free+0xad/0x134
[   60.223441]  [<ffffffff8106890a>] ? trace_hardirqs_on_caller+0x114/0x13f
[   60.223447]  [<ffffffff81068942>] ? trace_hardirqs_on+0xd/0xf
[   60.223454]  [<ffffffff810ed93f>] vfs_fstatat+0x32/0x5d
[   60.223460]  [<ffffffff810ed9bb>] vfs_lstat+0x19/0x1b
[   60.223465]  [<ffffffff810ed9d7>] sys_newlstat+0x1a/0x38
[   60.223471]  [<ffffffff8106890a>] ? trace_hardirqs_on_caller+0x114/0x13f
[   60.223477]  [<ffffffff813cec00>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   60.223485]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b
