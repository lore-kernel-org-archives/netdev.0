From: f6bvp <f6bvp@free.fr>
Subject: netrom circular locking dependency detected
Date: Thu, 17 Jan 2013 19:21:20 +0100
Message-ID: <50F84120.3020809@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020604050105030601020703"
To: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020604050105030601020703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Circular locking I reported a while ago is still present in kernel 3.7.2 
netrom module.
I include here /var/log/kernel relevant details for information.

73 de Bernard, f6bvp



--------------020604050105030601020703
Content-Type: text/plain;
 name="nr_circular_locking.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nr_circular_locking.txt"


Jan 13 12:05:39 f6bvp-8 kernel: [76938.785965] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.785980] ======================================================
Jan 13 12:05:39 f6bvp-8 kernel: [76938.785984] [ INFO: possible circular locking dependency detected ]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.785989] 3.7.2 #2 Not tainted
Jan 13 12:05:39 f6bvp-8 kernel: [76938.785993] -------------------------------------------------------
Jan 13 12:05:39 f6bvp-8 kernel: [76938.785997] ax25ipd/2093 is trying to acquire lock:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786001]  (nr_node_list_lock){+.-...}, at: [<ffffffffa06025ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] but task is already holding lock:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  (nr_neigh_list_lock){+.-...}, at: [<ffffffffa0602596>] nr_rt_device_down+0x26/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] which lock already depends on the new lock.
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] the existing dependency chain (in reverse order) is:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] -> #2 (nr_neigh_list_lock){+.-...}:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff810b80a2>] lock_acquire+0x92/0x120
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81491616>] _raw_spin_lock_bh+0x36/0x50
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa06019eb>] nr_remove_neigh+0x1b/0xb0 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa0602c20>] nr_rt_ioctl+0x2b0/0xa60 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa05fefa1>] nr_ioctl+0x51/0x1d0 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813a3cd0>] sock_do_ioctl+0x30/0x70
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813a4029>] sock_ioctl+0x79/0x2f0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81190808>] do_vfs_ioctl+0x98/0x560
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81190d61>] sys_ioctl+0x91/0xb0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8149a869>] system_call_fastpath+0x16/0x1b
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] -> #1 (&(&nr_node->node_lock)->rlock){+.-...}:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff810b80a2>] lock_acquire+0x92/0x120
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81491616>] _raw_spin_lock_bh+0x36/0x50
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa0601acc>] nr_node_show+0x4c/0x150 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff811a158c>] seq_read+0x26c/0x420
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff811e7226>] proc_reg_read+0x86/0xc0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8117ed1c>] vfs_read+0xac/0x180
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8117ee42>] sys_read+0x52/0xa0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8149a869>] system_call_fastpath+0x16/0x1b
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] -> #0 (nr_node_list_lock){+.-...}:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff810b78b3>] __lock_acquire+0x1c13/0x1e40
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff810b80a2>] lock_acquire+0x92/0x120
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81491616>] _raw_spin_lock_bh+0x36/0x50
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa06025ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa05ffb4d>] nr_device_event+0x7d/0xa0 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff814961c8>] notifier_call_chain+0x58/0xb0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff810824e6>] raw_notifier_call_chain+0x16/0x20
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813bac06>] call_netdevice_notifiers+0x36/0x60
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813badff>] dev_close_many+0xbf/0x100
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813baf18>] rollback_registered_many+0xd8/0x240
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813bb11d>] rollback_registered+0x2d/0x40
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813bdea8>] unregister_netdevice_queue+0x68/0xc0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813bdf20>] unregister_netdev+0x20/0x30
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffffa05f34e7>] mkiss_close+0x57/0x90 [mkiss]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81313861>] tty_ldisc_close.isra.2+0x41/0x60
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81313ad0>] tty_ldisc_reinit+0x40/0x80
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff81314287>] tty_ldisc_hangup+0x197/0x340
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8130b86a>] __tty_hangup+0x10a/0x3c0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8130bb4e>] tty_vhangup+0xe/0x10
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff813161d9>] pty_close+0x109/0x180
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8130cb06>] tty_release+0x156/0x580
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8117fd5e>] __fput+0xae/0x230
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8117feee>] ____fput+0xe/0x10
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8107811c>] task_work_run+0xbc/0xe0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8105b4cf>] do_exit+0x17f/0x8f0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8105c0be>] do_group_exit+0x4e/0xc0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8105c147>] sys_exit_group+0x17/0x20
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        [<ffffffff8149a869>] system_call_fastpath+0x16/0x1b
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] other info that might help us debug this:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] Chain exists of:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]   nr_node_list_lock --> &(&nr_node->node_lock)->rlock --> nr_neigh_list_lock
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  Possible unsafe locking scenario:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        CPU0                    CPU1
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]        ----                    ----
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]   lock(nr_neigh_list_lock);
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]                                lock(&(&nr_node->node_lock)->rlock);
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]                                lock(nr_neigh_list_lock);
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]   lock(nr_node_list_lock);
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  *** DEADLOCK ***
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 4 locks held by ax25ipd/2093:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  #0:  (&tty->legacy_mutex){+.+.+.}, at: [<ffffffff81491d82>] tty_lock_nested+0x42/0x90
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  #1:  (&tty->ldisc_mutex){+.+.+.}, at: [<ffffffff8131420a>] tty_ldisc_hangup+0x11a/0x340
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813cd707>] rtnl_lock+0x17/0x20
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  #3:  (nr_neigh_list_lock){+.-...}, at: [<ffffffffa0602596>] nr_rt_device_down+0x26/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] 
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] stack backtrace:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] Pid: 2093, comm: ax25ipd Not tainted 3.7.2 #2
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006] Call Trace:
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff814884e9>] print_circular_bug+0x289/0x29a
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff810b78b3>] __lock_acquire+0x1c13/0x1e40
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa06025ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff810b80a2>] lock_acquire+0x92/0x120
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa06025ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81491616>] _raw_spin_lock_bh+0x36/0x50
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa06025ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff810b8b15>] ? trace_hardirqs_on_caller+0x105/0x190
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa05ffb41>] ? nr_device_event+0x71/0xa0 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa06025ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8105e2c7>] ? local_bh_enable_ip+0x97/0x100
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa05ffb4d>] nr_device_event+0x7d/0xa0 [netrom]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff814961c8>] notifier_call_chain+0x58/0xb0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff810824e6>] raw_notifier_call_chain+0x16/0x20
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813bac06>] call_netdevice_notifiers+0x36/0x60
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813badff>] dev_close_many+0xbf/0x100
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813baf18>] rollback_registered_many+0xd8/0x240
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813bb11d>] rollback_registered+0x2d/0x40
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813bdea8>] unregister_netdevice_queue+0x68/0xc0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813bdf20>] unregister_netdev+0x20/0x30
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffffa05f34e7>] mkiss_close+0x57/0x90 [mkiss]
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81313861>] tty_ldisc_close.isra.2+0x41/0x60
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81313ad0>] tty_ldisc_reinit+0x40/0x80
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81314287>] tty_ldisc_hangup+0x197/0x340
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8130b86a>] __tty_hangup+0x10a/0x3c0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8130bb4e>] tty_vhangup+0xe/0x10
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff813161d9>] pty_close+0x109/0x180
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8130cb06>] tty_release+0x156/0x580
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81195952>] ? dput+0x62/0x1b0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8117fd5e>] __fput+0xae/0x230
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8117feee>] ____fput+0xe/0x10
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8107811c>] task_work_run+0xbc/0xe0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8105b4cf>] do_exit+0x17f/0x8f0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff81153008>] ? do_munmap+0x2c8/0x3a0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff814920d8>] ? retint_swapgs+0x13/0x1b
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8105c0be>] do_group_exit+0x4e/0xc0
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8105c147>] sys_exit_group+0x17/0x20
Jan 13 12:05:39 f6bvp-8 kernel: [76938.786006]  [<ffffffff8149a869>] system_call_fastpath+0x16/0x1b
Jan 13 12:06:20 f6bvp-8 kernel: [76979.963779] mkiss: ax0: crc mode is auto.
Jan 13 12:06:20 f6bvp-8 kernel: [76979.964864] IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready

--------------020604050105030601020703--
