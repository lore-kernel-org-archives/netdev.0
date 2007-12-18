From: "Miles Lane" <miles.lane@gmail.com>
Subject: 2.6.24-rc5-mm1 -- INFO: possible circular locking dependency detected -- pm-suspend/5800 is trying to acquire lock
Date: Tue, 18 Dec 2007 09:03:01 -0500
Message-ID: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net,
	"Len Brown" <len.brown@intel.c
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757937AbXLROD2@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have only seen this happen once, and cannot reproduce it.  I'll keep
trying, though.

Dec 16 22:10:48 syntropy kernel: [  231.718023]
=======================================================
Dec 16 22:10:48 syntropy kernel: [  231.718025] [ INFO: possible
circular locking dependency detected ]
Dec 16 22:10:48 syntropy kernel: [  231.718028] 2.6.24-rc5-mm1 #7
Dec 16 22:10:48 syntropy kernel: [  231.718029]
-------------------------------------------------------
Dec 16 22:10:48 syntropy kernel: [  231.718032] pm-suspend/5800 is
trying to acquire lock:
Dec 16 22:10:48 syntropy kernel: [  231.718034]
(&(&priv->init_alive_start)->work){--..}, at:
[__cancel_work_timer+0x8a/0x17f] __cancel_work_timer+0x8a/0x17f
Dec 16 22:10:48 syntropy kernel: [  231.718045]
Dec 16 22:10:48 syntropy kernel: [  231.718046] but task is already
holding lock:
Dec 16 22:10:48 syntropy kernel: [  231.718047]  (&priv->mutex){--..},
at: [<f8a587e7>] iwl3945_pci_suspend+0x1d/0x65 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718065]
Dec 16 22:10:48 syntropy kernel: [  231.718066] which lock already
depends on the new lock.
Dec 16 22:10:48 syntropy kernel: [  231.718067]
Dec 16 22:10:48 syntropy kernel: [  231.718068]
Dec 16 22:10:48 syntropy kernel: [  231.718069] the existing
dependency chain (in reverse order) is:
Dec 16 22:10:48 syntropy kernel: [  231.718071]
Dec 16 22:10:48 syntropy kernel: [  231.718072] -> #1 (&priv->mutex){--..}:
Dec 16 22:10:48 syntropy kernel: [  231.718075]
[__lock_acquire+0xa17/0xbf4] __lock_acquire+0xa17/0xbf4
Dec 16 22:10:48 syntropy kernel: [  231.718083]
[mac80211:lock_acquire+0x76/0x1d8] lock_acquire+0x76/0x9d
Dec 16 22:10:48 syntropy kernel: [  231.718088]
[pcmcia:mutex_lock_nested+0xf7/0xd7d] mutex_lock_nested+0xf7/0x294
Dec 16 22:10:48 syntropy kernel: [  231.718096]        [<f8a56ff7>]
iwl3945_bg_init_alive_start+0x2d/0x1d7 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718109]
[run_workqueue+0xbb/0x18b] run_workqueue+0xbb/0x18b
Dec 16 22:10:48 syntropy kernel: [  231.718115]
[worker_thread+0xbe/0xcd] worker_thread+0xbe/0xcd
Dec 16 22:10:48 syntropy kernel: [  231.718121]
[kthread+0x3b/0x61] kthread+0x3b/0x61
Dec 16 22:10:48 syntropy kernel: [  231.718126]
[kernel_thread_helper+0x7/0x10] kernel_thread_helper+0x7/0x10
Dec 16 22:10:48 syntropy kernel: [  231.718133]        [<ffffffff>] 0xffffffff
Dec 16 22:10:48 syntropy kernel: [  231.718145]
Dec 16 22:10:48 syntropy kernel: [  231.718146] -> #0
(&(&priv->init_alive_start)->work){--..}:
Dec 16 22:10:48 syntropy kernel: [  231.718149]
[__lock_acquire+0x93e/0xbf4] __lock_acquire+0x93e/0xbf4
Dec 16 22:10:48 syntropy kernel: [  231.718155]
[mac80211:lock_acquire+0x76/0x1d8] lock_acquire+0x76/0x9d
Dec 16 22:10:48 syntropy kernel: [  231.718161]
[__cancel_work_timer+0xb3/0x17f] __cancel_work_timer+0xb3/0x17f
Dec 16 22:10:48 syntropy kernel: [  231.718167]
[iwl3945:cancel_delayed_work_sync+0xb/0x0d]
cancel_delayed_work_sync+0xb/0xd
Dec 16 22:10:48 syntropy kernel: [  231.718173]        [<f8a542cb>]
__iwl3945_down+0x51/0x310 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718184]        [<f8a587f7>]
iwl3945_pci_suspend+0x2d/0x65 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718196]
[pci_device_suspend+0x1b/0x4b] pci_device_suspend+0x1b/0x4b
Dec 16 22:10:48 syntropy kernel: [  231.718203]
[device_suspend+0x17e/0x259] device_suspend+0x17e/0x259
Dec 16 22:10:48 syntropy kernel: [  231.718210]
[suspend_devices_and_enter+0x3d/0x138]
suspend_devices_and_enter+0x3d/0x138
Dec 16 22:10:48 syntropy kernel: [  231.718217]
[enter_state+0x121/0x17d] enter_state+0x121/0x17d
Dec 16 22:10:48 syntropy kernel: [  231.718222]
[state_store+0x96/0xac] state_store+0x96/0xac
Dec 16 22:10:48 syntropy kernel: [  231.718228]
[kobj_attr_store+0x1a/0x22] kobj_attr_store+0x1a/0x22
Dec 16 22:10:48 syntropy kernel: [  231.718234]
[sysfs_write_file+0xb8/0xe3] sysfs_write_file+0xb8/0xe3
Dec 16 22:10:48 syntropy kernel: [  231.718242]
[vfs_write+0xa4/0x120] vfs_write+0xa4/0x120
Dec 16 22:10:48 syntropy kernel: [  231.718248]
[sys_write+0x3b/0x60] sys_write+0x3b/0x60
Dec 16 22:10:48 syntropy kernel: [  231.718254]
[sysenter_past_esp+0x6b/0xc1] sysenter_past_esp+0x6b/0xc1
Dec 16 22:10:48 syntropy kernel: [  231.718259]        [<ffffffff>] 0xffffffff
Dec 16 22:10:48 syntropy kernel: [  231.718269]
Dec 16 22:10:48 syntropy kernel: [  231.718269] other info that might
help us debug this:
Dec 16 22:10:48 syntropy kernel: [  231.718271]
Dec 16 22:10:48 syntropy kernel: [  231.718272] 4 locks held by pm-suspend/5800:
Dec 16 22:10:48 syntropy kernel: [  231.718274]  #0:
(&buffer->mutex){--..}, at: [sysfs_write_file+0x25/0xe3]
sysfs_write_file+0x25/0xe3
Dec 16 22:10:48 syntropy kernel: [  231.718280]  #1:
(pm_mutex){--..}, at: [enter_state+0x166/0x17d]
enter_state+0x166/0x17d
Dec 16 22:10:48 syntropy kernel: [  231.718286]  #2:  (dpm_mtx){--..},
at: [device_suspend+0x2b/0x259] device_suspend+0x2b/0x259
Dec 16 22:10:48 syntropy kernel: [  231.718291]  #3:
(&priv->mutex){--..}, at: [<f8a587e7>] iwl3945_pci_suspend+0x1d/0x65
[iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718304]
Dec 16 22:10:48 syntropy kernel: [  231.718304] stack backtrace:
Dec 16 22:10:48 syntropy kernel: [  231.718307] Pid: 5800, comm:
pm-suspend Not tainted 2.6.24-rc5-mm1 #7
Dec 16 22:10:48 syntropy kernel: [  231.718310]
[show_trace_log_lvl+0x12/0x25] show_trace_log_lvl+0x12/0x25
Dec 16 22:10:48 syntropy kernel: [  231.718314]  [show_trace+0xd/0x10]
show_trace+0xd/0x10
Dec 16 22:10:48 syntropy kernel: [  231.718318]
[sbp2:dump_stack+0x57/0x1734] dump_stack+0x57/0x5f
Dec 16 22:10:48 syntropy kernel: [  231.718321]
[print_circular_bug_tail+0x5b/0x66] print_circular_bug_tail+0x5b/0x66
Dec 16 22:10:48 syntropy kernel: [  231.718325]
[__lock_acquire+0x93e/0xbf4] __lock_acquire+0x93e/0xbf4
Dec 16 22:10:48 syntropy kernel: [  231.718329]
[mac80211:lock_acquire+0x76/0x1d8] lock_acquire+0x76/0x9d
Dec 16 22:10:48 syntropy kernel: [  231.718332]
[__cancel_work_timer+0xb3/0x17f] __cancel_work_timer+0xb3/0x17f
Dec 16 22:10:48 syntropy kernel: [  231.718336]
[iwl3945:cancel_delayed_work_sync+0xb/0x0d]
cancel_delayed_work_sync+0xb/0xd
Dec 16 22:10:48 syntropy kernel: [  231.718340]  [<f8a542cb>]
__iwl3945_down+0x51/0x310 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718350]  [<f8a587f7>]
iwl3945_pci_suspend+0x2d/0x65 [iwl3945]
Dec 16 22:10:48 syntropy kernel: [  231.718360]
[pci_device_suspend+0x1b/0x4b] pci_device_suspend+0x1b/0x4b
Dec 16 22:10:48 syntropy kernel: [  231.718363]
[device_suspend+0x17e/0x259] device_suspend+0x17e/0x259
Dec 16 22:10:48 syntropy kernel: [  231.718367]
[suspend_devices_and_enter+0x3d/0x138]
suspend_devices_and_enter+0x3d/0x138
Dec 16 22:10:48 syntropy kernel: [  231.718371]
[enter_state+0x121/0x17d] enter_state+0x121/0x17d
Dec 16 22:10:48 syntropy kernel: [  231.718374]
[state_store+0x96/0xac] state_store+0x96/0xac
Dec 16 22:10:48 syntropy kernel: [  231.718378]
[kobj_attr_store+0x1a/0x22] kobj_attr_store+0x1a/0x22
Dec 16 22:10:48 syntropy kernel: [  231.718381]
[sysfs_write_file+0xb8/0xe3] sysfs_write_file+0xb8/0xe3
Dec 16 22:10:48 syntropy kernel: [  231.718385]
[vfs_write+0xa4/0x120] vfs_write+0xa4/0x120
Dec 16 22:10:48 syntropy kernel: [  231.718388]  [sys_write+0x3b/0x60]
sys_write+0x3b/0x60
Dec 16 22:10:48 syntropy kernel: [  231.718391]
[sysenter_past_esp+0x6b/0xc1] sysenter_past_esp+0x6b/0xc1
Dec 16 22:10:48 syntropy kernel: [  231.718395]  =======================
