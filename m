From: Peter Wu <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>
Subject: (4.3.0) r8152: deadlock related to runtime suspend?
Date: Sat, 5 Dec 2015 11:59:12 +0100
Message-ID: <20151205105912.GA1766@al>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I rarely use a Realtek USB 3.0 Gigabit Ethernet adapter (vid/pid
0bda:8153), but when I did last night, it resulted in a lockup of
processes doing networking ("ip link", "ping", "ethtool", ...).

A (few) minute(s) before that event, I noticed that there was no network
connectivity (ping hung) which was somehow solved by invoking "ethtool
eth1" (triggering runtime pm wakeup?). This same trick did not work at
the next event. Invoking "ethtool eth1", "ip link", etc. hung completely
and interrupt (^C) did not work at all.

Since that did not work, I pulled the USB adapter and re-inserted it,
hoping it would reset things. That did not work at all, there was a
"usb disconnect" message, but no further driver messages.

Fast forward an hour, and it has become a disaster. I have terminated
and killed many programs via SysRq but am still unable to get a stable
system that does not hang on network I/O. Even the suspend process
fails so in the end I attempted to shutdown the system. After half an
hour after getting the poweroff message, I issued SysRq + B to reboot
(since SysRq + O did not shut down either).

Attached are logs with various various backtraces from SysRq and failed
suspend. Let me know if you need more information!

By the way, often I have to rmmod xhci and re-insert it, otherwise
plugging it in does not result in a detection. A USB 2.0 port does not
have this problem (runtime PM is enabled for all devices). This is the
USB 3.0 port:

    02:00.0 USB controller [0c03]: NEC Corporation uPD720200 USB 3.0
    Host Controller [1033:0194] (rev 03)
-- 
Kind regards,
Peter Wu
https://lekensteyn.nl

--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="journal.txt"
Content-Transfer-Encoding: quoted-printable

Dec 05 00:32:58 al kernel: usb 3-1: USB disconnect, device number 4
Dec 05 00:34:43 al NetworkManager[441]: <warn>  Could not get scan request =
result: Timeout was reached
Dec 05 00:35:45 al NetworkManager[441]: <warn>  Could not get scan request =
result: Timeout was reached
Dec 05 00:36:13 al kernel: INFO: task wpa_supplicant:573 blocked for more t=
han 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: wpa_supplicant  D ffff88023bc956c0     0   573  =
    1 0x00000000
Dec 05 00:36:13 al kernel:  ffff8800aca2fa48 0000000000000086 ffff880232600=
c80 ffff88022d101900
Dec 05 00:36:13 al kernel:  ffff8800aca30000 ffffffff818b4504 ffff88022d101=
900 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff8800aca2fa60 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffffa05c782b>] nl80211_pre_doit+0xeb/0x18=
0 [cfg80211]
Dec 05 00:36:13 al kernel:  [<ffffffff814af5a8>] genl_family_rcv_msg+0x1c8/=
0x3c0
Dec 05 00:36:13 al kernel:  [<ffffffff814af7a0>] ? genl_family_rcv_msg+0x3c=
0/0x3c0
Dec 05 00:36:13 al kernel:  [<ffffffff814af816>] genl_rcv_msg+0x76/0xb0
Dec 05 00:36:13 al kernel:  [<ffffffff814ae844>] netlink_rcv_skb+0xa4/0xc0
Dec 05 00:36:13 al kernel:  [<ffffffff814af3c8>] genl_rcv+0x28/0x40
Dec 05 00:36:13 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:36:13 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:36:13 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:36:13 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:36:13 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task Qt bearer threa:8292 blocked for more=
 than 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: Qt bearer threa D ffff88023bd156c0     0  8292  =
 8222 0x00000000
Dec 05 00:36:13 al kernel:  ffff8800ac9bfc88 0000000000000086 ffff880232601=
900 ffff880214323200
Dec 05 00:36:13 al kernel:  ffff8800ac9c0000 ffffffff818b4504 ffff880214323=
200 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff8800ac9bfca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:36:13 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:36:13 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:36:13 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:36:13 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:36:13 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task ksysguardd:8310 blocked for more than=
 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: ksysguardd      D ffff88023bc156c0     0  8310  =
 8272 0x00000000
Dec 05 00:36:13 al kernel:  ffff8800a6b67ce8 0000000000000082 ffffffff81812=
500 ffff880205e04b00
Dec 05 00:36:13 al kernel:  ffff8800a6b68000 ffffffff818b4504 ffff880205e04=
b00 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff8800a6b67d00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:36:13 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:36:13 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:36:13 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:36:13 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:36:13 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:36:13 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task DNS Res~ver #11:22782 blocked for mor=
e than 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: DNS Res~ver #11 D ffff88023bc956c0     0 22782  =
 8222 0x00000000
Dec 05 00:36:13 al kernel:  ffff88007bf9fc88 0000000000000086 ffff880232600=
c80 ffff88023270d780
Dec 05 00:36:13 al kernel:  ffff88007bfa0000 ffffffff818b4504 ffff88023270d=
780 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff88007bf9fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:36:13 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:36:13 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:36:13 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:36:13 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task kworker/1:1:22090 blocked for more th=
an 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: kworker/1:1     D ffff88023bc956c0     0 22090  =
    2 0x00000000
Dec 05 00:36:13 al kernel: Workqueue: events rtl_work_func_t [r8152]
Dec 05 00:36:13 al kernel:  ffff8801d6f2fc38 0000000000000046 ffff880232600=
c80 ffff88021f7ee400
Dec 05 00:36:13 al kernel:  ffff8801d6f30000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:36:13 al kernel:  0000000000000000 ffff8801d6f2fc50 ffffffff8157a=
09a ffff880228935890
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:36:13 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff8138f321>] ? n_tty_receive_buf_common=
+0x131/0xca0
Dec 05 00:36:13 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:36:13 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:36:13 al kernel:  [<ffffffffa0a816a0>] rtl_work_func_t+0x70/0x410=
 [r8152]
Dec 05 00:36:13 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff81393468>] ? flush_to_ldisc+0xa8/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:36:13 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:36:13 al kernel:  [<ffffffff81579940>] ? __schedule+0x340/0xa60
Dec 05 00:36:13 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:36:13 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:36:13 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel: INFO: task kworker/0:1:22654 blocked for more th=
an 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: kworker/0:1     D 0000000000000000     0 22654  =
    2 0x00000000
Dec 05 00:36:13 al kernel: Workqueue: usb_hub_wq hub_event [usbcore]
Dec 05 00:36:13 al kernel:  ffff8800447f7ab0 0000000000000046 ffff8802327c6=
400 ffff8801d7e4a580
Dec 05 00:36:13 al kernel:  ffff8800447f8000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:36:13 al kernel:  0000000000000000 ffff8800447f7ac8 ffffffff8157a=
09a ffff880228935890
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:36:13 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:36:13 al kernel:  [<ffffffff813da963>] __device_release_driver+0x=
43/0x150
Dec 05 00:36:13 al kernel:  [<ffffffff813daa93>] device_release_driver+0x23=
/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff813da0f1>] bus_remove_device+0x101/0x=
170
Dec 05 00:36:13 al kernel:  [<ffffffff813d63c9>] device_del+0x139/0x260
Dec 05 00:36:13 al kernel:  [<ffffffffa0203f3f>] ? usb_remove_ep_devs+0x1f/=
0x30 [usbcore]
Dec 05 00:36:13 al kernel:  [<ffffffffa01fcff9>] usb_disable_device+0x89/0x=
270 [usbcore]
Dec 05 00:36:13 al kernel:  [<ffffffffa01f2ce2>] usb_disconnect+0x92/0x2b0 =
[usbcore]
Dec 05 00:36:13 al kernel:  [<ffffffffa01f4eb7>] hub_event+0x737/0x1520 [us=
bcore]
Dec 05 00:36:13 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:36:13 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:36:13 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:36:13 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel: INFO: task kworker/2:1:23024 blocked for more th=
an 120 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: kworker/2:1     D ffff88023bd156c0     0 23024  =
    2 0x00000000
Dec 05 00:36:13 al kernel: Workqueue: ipv6_addrconf addrconf_verify_work
Dec 05 00:36:13 al kernel:  ffff8802057b3d58 0000000000000046 ffff880228897=
080 ffff880214112580
Dec 05 00:36:13 al kernel:  ffff8802057b4000 ffffffff818b4504 ffff880214112=
580 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff8802057b3d70 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8152d23e>] addrconf_verify_work+0xe/0=
x20
Dec 05 00:36:13 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:36:13 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:36:13 al kernel:  [<ffffffff81579940>] ? __schedule+0x340/0xa60
Dec 05 00:36:13 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:36:13 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:36:13 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:36:13 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:36:13 al kernel: INFO: task ping:23097 blocked for more than 120 =
seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: ping            D 0000000000000000     0 23097  =
23091 0x00000002
Dec 05 00:36:13 al kernel:  ffff880037367ca8 0000000000000046 ffff8801d7e4a=
580 ffff8802327c5780
Dec 05 00:36:13 al kernel:  ffff880037368000 ffffffff818b4504 ffff8802327c5=
780 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff880037367cc0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff815583fd>] ip6mr_sk_done+0x2d/0xe0
Dec 05 00:36:13 al kernel:  [<ffffffff815437fd>] rawv6_close+0x1d/0x40
Dec 05 00:36:13 al kernel:  [<ffffffff814f258f>] inet_release+0x3f/0x60
Dec 05 00:36:13 al kernel:  [<ffffffff81521290>] inet6_release+0x30/0x40
Dec 05 00:36:13 al kernel:  [<ffffffff8145f53f>] sock_release+0x1f/0x80
Dec 05 00:36:13 al kernel:  [<ffffffff8145f5b2>] sock_close+0x12/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff811d61dc>] __fput+0x9c/0x1f0
Dec 05 00:36:13 al kernel:  [<ffffffff811d636e>] ____fput+0xe/0x10
Dec 05 00:36:13 al kernel:  [<ffffffff81091173>] task_work_run+0x73/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff81077c85>] do_exit+0x395/0xb40
Dec 05 00:36:13 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff810784ab>] do_group_exit+0x3b/0xb0
Dec 05 00:36:13 al kernel:  [<ffffffff81078534>] SyS_exit_group+0x14/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task ethtool:23105 blocked for more than 1=
20 seconds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: ethtool         D 0000000000000003     0 23105  =
23099 0x00000000
Dec 05 00:36:13 al kernel:  ffff8800a6b53b28 0000000000000086 ffff880230ab8=
000 ffff88021f723200
Dec 05 00:36:13 al kernel:  ffff8800a6b54000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:36:13 al kernel:  0000000000000000 ffff8800a6b53b40 ffffffff8157a=
09a ffff880228935890
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:36:13 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:36:13 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:36:13 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:36:13 al kernel:  [<ffffffffa0a8042a>] rtl8152_get_settings+0x2a/=
0x80 [r8152]
Dec 05 00:36:13 al kernel:  [<ffffffff81480df7>] __ethtool_get_settings+0x6=
7/0xa0
Dec 05 00:36:13 al kernel:  [<ffffffff814827f7>] dev_ethtool+0x697/0x1da0
Dec 05 00:36:13 al kernel:  [<ffffffff81392fab>] ? tty_flip_buffer_push+0x2=
b/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff810b568d>] ? remove_wait_queue+0x4d/0=
x60
Dec 05 00:36:13 al kernel:  [<ffffffff8147603e>] ? dev_get_by_name_rcu+0x5e=
/0x80
Dec 05 00:36:13 al kernel:  [<ffffffff81494c42>] dev_ioctl+0x182/0x590
Dec 05 00:36:13 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8138a651>] ? tty_write+0x1c1/0x2d0
Dec 05 00:36:13 al kernel:  [<ffffffff8145e2f2>] sock_do_ioctl+0x42/0x50
Dec 05 00:36:13 al kernel:  [<ffffffff8145e7f2>] sock_ioctl+0x1d2/0x290
Dec 05 00:36:13 al kernel:  [<ffffffff811e64d5>] do_vfs_ioctl+0x295/0x480
Dec 05 00:36:13 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff811e6739>] SyS_ioctl+0x79/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:13 al kernel: INFO: task ip:23119 blocked for more than 120 se=
conds.
Dec 05 00:36:13 al kernel:       Tainted: G           O    4.3.0-1-ARCH #1
Dec 05 00:36:13 al kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_sec=
s" disables this message.
Dec 05 00:36:13 al kernel: ip              D ffff88023bc156c0     0 23119  =
23118 0x00000000
Dec 05 00:36:13 al kernel:  ffff8800a6bd7c88 0000000000000082 ffffffff81812=
500 ffff880214115780
Dec 05 00:36:13 al kernel:  ffff8800a6bd8000 ffffffff818b4504 ffff880214115=
780 00000000ffffffff
Dec 05 00:36:13 al kernel:  ffffffff818b4508 ffff8800a6bd7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:36:13 al kernel: Call Trace:
Dec 05 00:36:13 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:36:13 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:36:13 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:36:13 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:36:13 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:36:13 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:36:13 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:36:13 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:36:13 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:36:13 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:36:37 al kernel: sysrq: SysRq : Show backtrace of all active CPUs
Dec 05 00:36:37 al kernel: Sending NMI to all CPUs:
Dec 05 00:36:37 al kernel: NMI backtrace for cpu 0
Dec 05 00:36:37 al kernel: CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:37 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:37 al kernel: task: ffffffff81812500 ti: ffffffff81800000 task=
=2Eti: ffffffff81800000
Dec 05 00:36:37 al kernel: RIP: 0010:[<ffffffff812c7aa0>]  [<ffffffff812c7a=
a0>] __delay+0x0/0x20
Dec 05 00:36:37 al kernel: RSP: 0018:ffff88023bc03c00  EFLAGS: 00000817
Dec 05 00:36:37 al kernel: RAX: 0000000027c31860 RBX: 0000000000002710 RCX:=
 0000000002a47fa7
Dec 05 00:36:37 al kernel: RDX: 0000000000289719 RSI: 0000000000000080 RDI:=
 000000000028971a
Dec 05 00:36:37 al kernel: RBP: ffff88023bc03c08 R08: 000000000000000a R09:=
 0000000000001c13
Dec 05 00:36:37 al kernel: R10: 0000000000000026 R11: 0000000000001c13 R12:=
 0000000000000001
Dec 05 00:36:37 al kernel: R13: ffffffff81051e30 R14: ffffffff81897240 R15:=
 0000000000000001
Dec 05 00:36:37 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc00000(=
0000) knlGS:0000000000000000
Dec 05 00:36:37 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:37 al kernel: CR2: 00007f5189190750 CR3: 000000000180b000 CR4:=
 00000000000006f0
Dec 05 00:36:37 al kernel: Stack:
Dec 05 00:36:37 al kernel:  ffffffff812c7aed ffff88023bc03c50 ffffffff812c0=
34a 0000000000000010
Dec 05 00:36:37 al kernel:  ffff88023bc03c80 000000000000006c 0000000000000=
004 0000000000000001
Dec 05 00:36:37 al kernel:  ffffffff81897240 0000000000000001 ffff88023bc03=
c60 ffffffff81051ea9
Dec 05 00:36:37 al kernel: Call Trace:
Dec 05 00:36:37 al kernel:  <IRQ> =01d [<ffffffff812c7aed>] ? __const_udela=
y+0x2d/0x30
Dec 05 00:36:37 al kernel:  [<ffffffff812c034a>] nmi_trigger_all_cpu_backtr=
ace+0xfa/0x2a0
Dec 05 00:36:37 al kernel:  [<ffffffff81051ea9>] arch_trigger_all_cpu_backt=
race+0x19/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff813956e3>] sysrq_handle_showallcpus+0=
x13/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff81395d8f>] __handle_sysrq+0xef/0x140
Dec 05 00:36:37 al kernel:  [<ffffffff81396193>] sysrq_filter+0x383/0x3d0
Dec 05 00:36:37 al kernel:  [<ffffffff81415a4a>] input_to_handler+0x5a/0x100
Dec 05 00:36:37 al kernel:  [<ffffffff81417659>] input_pass_values.part.1+0=
x179/0x190
Dec 05 00:36:37 al kernel:  [<ffffffff81417983>] input_handle_event+0xc3/0x=
4e0
Dec 05 00:36:37 al kernel:  [<ffffffff81417df8>] input_event+0x58/0x80
Dec 05 00:36:37 al kernel:  [<ffffffffa030c892>] atkbd_interrupt+0x4d2/0x7f=
0 [atkbd]
Dec 05 00:36:37 al kernel:  [<ffffffffa0062ec6>] serio_interrupt+0x46/0x90 =
[serio]
Dec 05 00:36:37 al kernel:  [<ffffffffa00a3662>] i8042_interrupt+0x1f2/0x3c=
0 [i8042]
Dec 05 00:36:37 al kernel:  [<ffffffff810cce59>] handle_irq_event_percpu+0x=
39/0x1b0
Dec 05 00:36:37 al kernel:  [<ffffffff810cd010>] handle_irq_event+0x40/0x60
Dec 05 00:36:37 al kernel:  [<ffffffff810d002b>] handle_edge_irq+0xab/0x130
Dec 05 00:36:37 al kernel:  [<ffffffff81018c8a>] handle_irq+0x1a/0x30
Dec 05 00:36:37 al kernel:  [<ffffffff8158082b>] do_IRQ+0x4b/0xd0
Dec 05 00:36:37 al kernel:  [<ffffffff8157e602>] common_interrupt+0x82/0x82
Dec 05 00:36:37 al kernel:  <EOI> =01d [<ffffffff814363d1>] ? cpuidle_enter=
_state+0x121/0x290
Dec 05 00:36:37 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:36:37 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:36:37 al kernel:  [<ffffffff81571b79>] rest_init+0x89/0x90
Dec 05 00:36:37 al kernel:  [<ffffffff81904013>] start_kernel+0x483/0x4a4
Dec 05 00:36:37 al kernel:  [<ffffffff81903120>] ? early_idt_handler_array+=
0x120/0x120
Dec 05 00:36:37 al kernel:  [<ffffffff81903339>] x86_64_start_reservations+=
0x2a/0x2c
Dec 05 00:36:37 al kernel:  [<ffffffff81903485>] x86_64_start_kernel+0x14a/=
0x16d
Dec 05 00:36:37 al kernel: Code: d1 0f 01 fb 0f ae e8 0f 31 48 c1 e2 20 48 =
09 d0 48 89 c2 48 29 f2 48 39 d7 77 b9 5b 41 5c 5d c3 90 66 2e 0f 1f 84 00 =
00 00 00 00 <66> 66 66 66 90 55 48 89 e5 ff 15 e9 4f 5c 00 5d c3 0f 1f 44 0=
0=20
Dec 05 00:36:37 al kernel: NMI backtrace for cpu 1
Dec 05 00:36:37 al kernel: CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:37 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:37 al kernel: task: ffff880232600c80 ti: ffff880232608000 task=
=2Eti: ffff880232608000
Dec 05 00:36:37 al kernel: RIP: 0010:[<ffffffff812bd901>]  [<ffffffff812bd9=
01>] int_sqrt+0x31/0x40
Dec 05 00:36:37 al kernel: RSP: 0018:ffff88023260be50  EFLAGS: 00000016
Dec 05 00:36:37 al kernel: RAX: 0000000000000000 RBX: ffff88023bc92844 RCX:=
 000000000000001c
Dec 05 00:36:37 al kernel: RDX: 0010000000000000 RSI: 0040000000000000 RDI:=
 00000000000fb298
Dec 05 00:36:37 al kernel: RBP: ffff88023260be50 R08: 00000000000085f2 R09:=
 ffff88023bc92810
Dec 05 00:36:37 al kernel: R10: 0000000000000000 R11: 0000000000002119 R12:=
 00000000000004ba
Dec 05 00:36:37 al kernel: R13: 0000000000000007 R14: 0000000000000b29 R15:=
 ffff88023bc92864
Dec 05 00:36:37 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc80000(=
0000) knlGS:0000000000000000
Dec 05 00:36:37 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:37 al kernel: CR2: 00007f5184b54af8 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:37 al kernel: Stack:
Dec 05 00:36:37 al kernel:  ffff88023260bec0 ffffffff81437b6f ffff88023bc9c=
b00 77359400814363af
Dec 05 00:36:37 al kernel:  ffff88023bc92800 ffffffff818919a0 0000000000000=
000 0000000000000000
Dec 05 00:36:37 al kernel:  3e6b2308d22ecf91 ffff88023260c000 ffffffff818e0=
190 ffff88023bc9cb00
Dec 05 00:36:37 al kernel: Call Trace:
Dec 05 00:36:37 al kernel:  [<ffffffff81437b6f>] menu_select+0x15f/0x3f0
Dec 05 00:36:37 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:36:37 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:37 al kernel: Code: 89 e5 76 2e b9 20 00 00 00 31 c0 48 ba 00 =
00 00 00 00 00 00 40 48 8d 34 10 48 d1 e8 48 39 fe 77 06 48 29 f7 48 01 d0 =
48 c1 ea 02 <83> e9 01 75 e5 5d c3 48 89 f8 5d c3 90 90 90 55 48 89 e5 41 5=
7=20
Dec 05 00:36:37 al kernel: NMI backtrace for cpu 2
Dec 05 00:36:37 al kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:37 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:37 al kernel: task: ffff880232601900 ti: ffff88023260c000 task=
=2Eti: ffff88023260c000
Dec 05 00:36:37 al kernel: RIP: 0010:[<ffffffff81339a9e>]  [<ffffffff81339a=
9e>] intel_idle+0xbe/0x120
Dec 05 00:36:37 al kernel: RSP: 0018:ffff88023260fe40  EFLAGS: 00000046
Dec 05 00:36:37 al kernel: RAX: 0000000000000020 RBX: 0000000000000008 RCX:=
 0000000000000001
Dec 05 00:36:37 al kernel: RDX: 0000000000000000 RSI: ffff880232610000 RDI:=
 0000000000000002
Dec 05 00:36:37 al kernel: RBP: ffff88023260fe60 R08: 00000cc8b2d2b278 R09:=
 0000000000000018
Dec 05 00:36:37 al kernel: R10: 0000000000000002 R11: 0000000000003d72 R12:=
 0000000000000020
Dec 05 00:36:37 al kernel: R13: 0000000000000003 R14: 0000000000000004 R15:=
 ffffffff81891b38
Dec 05 00:36:37 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd00000(=
0000) knlGS:0000000000000000
Dec 05 00:36:37 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:37 al kernel: CR2: 00007f518b3da000 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:37 al kernel: Stack:
Dec 05 00:36:37 al kernel:  0000000000000004 ffffffff818919a0 ffff88023bd1c=
b00 0002568ad3df07e1
Dec 05 00:36:37 al kernel:  ffff88023260fea8 ffffffff81436397 000000003bd12=
800 ffffffff818919a0
Dec 05 00:36:37 al kernel:  ffff880232610000 ffffffff818e0190 ffff88023bd1c=
b00 ffff88023260c000
Dec 05 00:36:37 al kernel: Call Trace:
Dec 05 00:36:37 al kernel:  [<ffffffff81436397>] cpuidle_enter_state+0xe7/0=
x290
Dec 05 00:36:37 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:36:37 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:36:37 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:37 al kernel: Code: 48 8b 34 25 c4 2b 01 00 48 89 d1 48 8d 86 =
08 c0 ff ff 0f 01 c8 48 8b 86 08 c0 ff ff a8 08 75 0b b9 01 00 00 00 4c 89 =
e0 0f 01 c9 <65> 48 8b 04 25 c4 2b 01 00 f0 80 a0 0a c0 ff ff df 0f ae f0 4=
8=20
Dec 05 00:36:37 al kernel: NMI backtrace for cpu 3
Dec 05 00:36:37 al kernel: CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:37 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:37 al kernel: task: ffff880232602580 ti: ffff880232610000 task=
=2Eti: ffff880232610000
Dec 05 00:36:37 al kernel: RIP: 0010:[<ffffffff812bd904>]  [<ffffffff812bd9=
04>] int_sqrt+0x34/0x40
Dec 05 00:36:37 al kernel: RSP: 0018:ffff880232613e50  EFLAGS: 00000006
Dec 05 00:36:37 al kernel: RAX: 0000000000000000 RBX: ffff88023bd92844 RCX:=
 000000000000001d
Dec 05 00:36:37 al kernel: RDX: 0100000000000000 RSI: 0400000000000000 RDI:=
 00000000000faedd
Dec 05 00:36:37 al kernel: RBP: ffff880232613e50 R08: 0000000000001799 R09:=
 ffff88023bd9280c
Dec 05 00:36:37 al kernel: R10: 0000000000000000 R11: 00000000000020a7 R12:=
 00000000000004aa
Dec 05 00:36:37 al kernel: R13: 0000000000000007 R14: 0000000000000b50 R15:=
 ffff88023bd92864
Dec 05 00:36:37 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd80000(=
0000) knlGS:0000000000000000
Dec 05 00:36:37 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:37 al kernel: CR2: 00007f519c5a5ce2 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:37 al kernel: Stack:
Dec 05 00:36:37 al kernel:  ffff880232613ec0 ffffffff81437b6f ffff88023bd9c=
b00 77359400814363af
Dec 05 00:36:37 al kernel:  ffff88023bd92800 ffffffff818919a0 0000000000000=
000 0000000000000000
Dec 05 00:36:37 al kernel:  f8637a1d6e905864 ffff880232614000 ffffffff818e0=
190 ffff88023bd9cb00
Dec 05 00:36:37 al kernel: Call Trace:
Dec 05 00:36:37 al kernel:  [<ffffffff81437b6f>] menu_select+0x15f/0x3f0
Dec 05 00:36:37 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:36:37 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:36:37 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:37 al kernel: Code: 2e b9 20 00 00 00 31 c0 48 ba 00 00 00 00 =
00 00 00 40 48 8d 34 10 48 d1 e8 48 39 fe 77 06 48 29 f7 48 01 d0 48 c1 ea =
02 83 e9 01 <75> e5 5d c3 48 89 f8 5d c3 90 90 90 55 48 89 e5 41 57 41 56 4=
1=20
Dec 05 00:36:43 al kernel: sysrq: SysRq : Show backtrace of all active CPUs
Dec 05 00:36:43 al kernel: Sending NMI to all CPUs:
Dec 05 00:36:43 al kernel: NMI backtrace for cpu 0
Dec 05 00:36:43 al kernel: CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:43 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:43 al kernel: task: ffffffff81812500 ti: ffffffff81800000 task=
=2Eti: ffffffff81800000
Dec 05 00:36:43 al kernel: RIP: 0010:[<ffffffff812c7aa0>]  [<ffffffff812c7a=
a0>] __delay+0x0/0x20
Dec 05 00:36:43 al kernel: RSP: 0018:ffff88023bc03c00  EFLAGS: 00000817
Dec 05 00:36:43 al kernel: RAX: 0000000027c31860 RBX: 0000000000002710 RCX:=
 0000000002a47fa7
Dec 05 00:36:43 al kernel: RDX: 0000000000289719 RSI: 0000000000000080 RDI:=
 000000000028971a
Dec 05 00:36:43 al kernel: RBP: ffff88023bc03c08 R08: 000000000000000a R09:=
 0000000000001c90
Dec 05 00:36:43 al kernel: R10: 0000000000000026 R11: 0000000000001c90 R12:=
 0000000000000001
Dec 05 00:36:43 al kernel: R13: ffffffff81051e30 R14: ffffffff81897240 R15:=
 0000000000000001
Dec 05 00:36:43 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc00000(=
0000) knlGS:0000000000000000
Dec 05 00:36:43 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:43 al kernel: CR2: 00007f301760f000 CR3: 000000000180b000 CR4:=
 00000000000006f0
Dec 05 00:36:43 al kernel: Stack:
Dec 05 00:36:43 al kernel:  ffffffff812c7aed ffff88023bc03c50 ffffffff812c0=
34a 0000000000000010
Dec 05 00:36:43 al kernel:  ffff88023bc03c80 000000000000006c 0000000000000=
004 0000000000000001
Dec 05 00:36:43 al kernel:  ffffffff81897240 0000000000000001 ffff88023bc03=
c60 ffffffff81051ea9
Dec 05 00:36:43 al kernel: Call Trace:
Dec 05 00:36:43 al kernel:  <IRQ> =01d [<ffffffff812c7aed>] ? __const_udela=
y+0x2d/0x30
Dec 05 00:36:43 al kernel:  [<ffffffff812c034a>] nmi_trigger_all_cpu_backtr=
ace+0xfa/0x2a0
Dec 05 00:36:43 al kernel:  [<ffffffff81051ea9>] arch_trigger_all_cpu_backt=
race+0x19/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff813956e3>] sysrq_handle_showallcpus+0=
x13/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff81395d8f>] __handle_sysrq+0xef/0x140
Dec 05 00:36:43 al kernel:  [<ffffffff81396193>] sysrq_filter+0x383/0x3d0
Dec 05 00:36:43 al kernel:  [<ffffffff81415a4a>] input_to_handler+0x5a/0x100
Dec 05 00:36:43 al kernel:  [<ffffffff81417659>] input_pass_values.part.1+0=
x179/0x190
Dec 05 00:36:43 al kernel:  [<ffffffff81417983>] input_handle_event+0xc3/0x=
4e0
Dec 05 00:36:43 al kernel:  [<ffffffff81417df8>] input_event+0x58/0x80
Dec 05 00:36:43 al kernel:  [<ffffffffa030c892>] atkbd_interrupt+0x4d2/0x7f=
0 [atkbd]
Dec 05 00:36:43 al kernel:  [<ffffffffa0062ec6>] serio_interrupt+0x46/0x90 =
[serio]
Dec 05 00:36:43 al kernel:  [<ffffffffa00a3662>] i8042_interrupt+0x1f2/0x3c=
0 [i8042]
Dec 05 00:36:43 al kernel:  [<ffffffff810cce59>] handle_irq_event_percpu+0x=
39/0x1b0
Dec 05 00:36:43 al kernel:  [<ffffffff810cd010>] handle_irq_event+0x40/0x60
Dec 05 00:36:43 al kernel:  [<ffffffff810d002b>] handle_edge_irq+0xab/0x130
Dec 05 00:36:43 al kernel:  [<ffffffff81018c8a>] handle_irq+0x1a/0x30
Dec 05 00:36:43 al kernel:  [<ffffffff8158082b>] do_IRQ+0x4b/0xd0
Dec 05 00:36:43 al kernel:  [<ffffffff8157e602>] common_interrupt+0x82/0x82
Dec 05 00:36:43 al kernel:  <EOI> =01d [<ffffffff814363d1>] ? cpuidle_enter=
_state+0x121/0x290
Dec 05 00:36:43 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:36:43 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:36:43 al kernel:  [<ffffffff81571b79>] rest_init+0x89/0x90
Dec 05 00:36:43 al kernel:  [<ffffffff81904013>] start_kernel+0x483/0x4a4
Dec 05 00:36:43 al kernel:  [<ffffffff81903120>] ? early_idt_handler_array+=
0x120/0x120
Dec 05 00:36:43 al kernel:  [<ffffffff81903339>] x86_64_start_reservations+=
0x2a/0x2c
Dec 05 00:36:43 al kernel:  [<ffffffff81903485>] x86_64_start_kernel+0x14a/=
0x16d
Dec 05 00:36:43 al kernel: Code: d1 0f 01 fb 0f ae e8 0f 31 48 c1 e2 20 48 =
09 d0 48 89 c2 48 29 f2 48 39 d7 77 b9 5b 41 5c 5d c3 90 66 2e 0f 1f 84 00 =
00 00 00 00 <66> 66 66 66 90 55 48 89 e5 ff 15 e9 4f 5c 00 5d c3 0f 1f 44 0=
0=20
Dec 05 00:36:43 al kernel: NMI backtrace for cpu 1
Dec 05 00:36:43 al kernel: CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:43 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:43 al kernel: task: ffff880232600c80 ti: ffff880232608000 task=
=2Eti: ffff880232608000
Dec 05 00:36:43 al kernel: RIP: 0010:[<ffffffff81437b40>]  [<ffffffff81437b=
40>] menu_select+0x130/0x3f0
Dec 05 00:36:43 al kernel: RSP: 0018:ffff88023260be60  EFLAGS: 00000002
Dec 05 00:36:43 al kernel: RAX: 000000000035676d RBX: ffff88023bc92844 RCX:=
 0000000000001a44
Dec 05 00:36:43 al kernel: RDX: 0000000000000000 RSI: ffff88023bc92854 RDI:=
 0000000000001727
Dec 05 00:36:43 al kernel: RBP: ffff88023260bec0 R08: 0000000000044ef5 R09:=
 000000000000001c
Dec 05 00:36:43 al kernel: R10: 0000000000000001 R11: 0000000000002d48 R12:=
 000000000000078c
Dec 05 00:36:43 al kernel: R13: 0000000000000006 R14: 00000000000012d8 R15:=
 ffff88023bc92864
Dec 05 00:36:43 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc80000(=
0000) knlGS:0000000000000000
Dec 05 00:36:43 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:43 al kernel: CR2: 00007f51305fb000 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:43 al kernel: Stack:
Dec 05 00:36:43 al kernel:  ffff88023bc9cb00 77359400814363af ffff88023bc92=
800 ffffffff818919a0
Dec 05 00:36:43 al kernel:  0000000000000000 0000000000000000 3e6b2308d22ec=
f91 ffff88023260c000
Dec 05 00:36:43 al kernel:  ffffffff818e0190 ffff88023bc9cb00 ffff880232608=
000 ffffffff818919a0
Dec 05 00:36:43 al kernel: Call Trace:
Dec 05 00:36:43 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:36:43 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:43 al kernel: Code: c3 41 39 d6 44 0f 42 f2 48 83 c1 04 4c 39 =
f9 75 e1 41 83 fd 08 0f 84 a7 01 00 00 49 63 cd 4c 89 d8 31 d2 48 f7 f1 49 =
89 c4 31 c0 <8b> 0e 39 cf 72 0a 4c 29 e1 48 0f af c9 48 01 c8 48 83 c6 04 4=
9=20
Dec 05 00:36:43 al kernel: NMI backtrace for cpu 2
Dec 05 00:36:43 al kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:43 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:43 al kernel: task: ffff880232601900 ti: ffff88023260c000 task=
=2Eti: ffff88023260c000
Dec 05 00:36:43 al kernel: RIP: 0010:[<ffffffff81339a9e>]  [<ffffffff81339a=
9e>] intel_idle+0xbe/0x120
Dec 05 00:36:43 al kernel: RSP: 0018:ffff88023260fe40  EFLAGS: 00000046
Dec 05 00:36:43 al kernel: RAX: 0000000000000020 RBX: 0000000000000008 RCX:=
 0000000000000001
Dec 05 00:36:43 al kernel: RDX: 0000000000000000 RSI: ffff880232610000 RDI:=
 0000000000000002
Dec 05 00:36:43 al kernel: RBP: ffff88023260fe60 R08: 00000cccb528c894 R09:=
 0000000000000018
Dec 05 00:36:43 al kernel: R10: 0000000000000028 R11: 0000000000003965 R12:=
 0000000000000020
Dec 05 00:36:43 al kernel: R13: 0000000000000003 R14: 0000000000000004 R15:=
 ffffffff81891b38
Dec 05 00:36:43 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd00000(=
0000) knlGS:0000000000000000
Dec 05 00:36:43 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:43 al kernel: CR2: 00007f512f0b42d8 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:43 al kernel: Stack:
Dec 05 00:36:43 al kernel:  0000000000000004 ffffffff818919a0 ffff88023bd1c=
b00 0002568c55b622ba
Dec 05 00:36:43 al kernel:  ffff88023260fea8 ffffffff81436397 000000003bd12=
800 ffffffff818919a0
Dec 05 00:36:43 al kernel:  ffff880232610000 ffffffff818e0190 ffff88023bd1c=
b00 ffff88023260c000
Dec 05 00:36:43 al kernel: Call Trace:
Dec 05 00:36:43 al kernel:  [<ffffffff81436397>] cpuidle_enter_state+0xe7/0=
x290
Dec 05 00:36:43 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:36:43 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:36:43 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:43 al kernel: Code: 48 8b 34 25 c4 2b 01 00 48 89 d1 48 8d 86 =
08 c0 ff ff 0f 01 c8 48 8b 86 08 c0 ff ff a8 08 75 0b b9 01 00 00 00 4c 89 =
e0 0f 01 c9 <65> 48 8b 04 25 c4 2b 01 00 f0 80 a0 0a c0 ff ff df 0f ae f0 4=
8=20
Dec 05 00:36:43 al kernel: NMI backtrace for cpu 3
Dec 05 00:36:43 al kernel: CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:36:43 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:36:43 al kernel: task: ffff880232602580 ti: ffff880232610000 task=
=2Eti: ffff880232610000
Dec 05 00:36:43 al kernel: RIP: 0010:[<ffffffff81437b50>]  [<ffffffff81437b=
50>] menu_select+0x140/0x3f0
Dec 05 00:36:43 al kernel: RSP: 0018:ffff880232613e60  EFLAGS: 00000083
Dec 05 00:36:43 al kernel: RAX: 000000000138d96f RBX: ffff88023bd92844 RCX:=
 0000000000001705
Dec 05 00:36:43 al kernel: RDX: 0000000000000004 RSI: ffff88023bd92858 RDI:=
 00000000000016f6
Dec 05 00:36:43 al kernel: RBP: ffff880232613ec0 R08: 0000000000001799 R09:=
 000000000000001c
Dec 05 00:36:43 al kernel: R10: 0000000000000000 R11: 0000000000002cb6 R12:=
 0000000000000773
Dec 05 00:36:43 al kernel: R13: 0000000000000006 R14: 00000000000012d8 R15:=
 ffff88023bd92864
Dec 05 00:36:43 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd80000(=
0000) knlGS:0000000000000000
Dec 05 00:36:43 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:36:43 al kernel: CR2: 00007f5156307008 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:36:43 al kernel: Stack:
Dec 05 00:36:43 al kernel:  ffff88023bd9cb00 77359400814363af ffff88023bd92=
800 ffffffff818919a0
Dec 05 00:36:43 al kernel:  0000000000000000 0000000000000000 f8637a1d6e905=
864 ffff880232614000
Dec 05 00:36:43 al kernel:  ffffffff818e0190 ffff88023bd9cb00 ffff880232610=
000 ffffffff818919a0
Dec 05 00:36:43 al kernel: Call Trace:
Dec 05 00:36:43 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:36:43 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:36:43 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:36:43 al kernel: Code: e1 41 83 fd 08 0f 84 a7 01 00 00 49 63 cd =
4c 89 d8 31 d2 48 f7 f1 49 89 c4 31 c0 8b 0e 39 cf 72 0a 4c 29 e1 48 0f af =
c9 48 01 c8 <48> 83 c6 04 49 39 f7 75 e7 41 83 fd 08 74 4a 49 63 cd 31 d2 4=
8=20
Dec 05 00:36:48 al NetworkManager[441]: <warn>  Could not get scan request =
result: Timeout was reached
Dec 05 00:37:48 al kernel: sysrq: SysRq : Show Blocked State
Dec 05 00:37:48 al kernel:   task                        PC stack   pid fat=
her
Dec 05 00:37:48 al kernel: ntpd            D ffff88023bc956c0     0   518  =
    1 0x00000004
Dec 05 00:37:48 al kernel:  ffff880231a97c88 0000000000000082 ffff880232600=
c80 ffff88022daf6400
Dec 05 00:37:48 al kernel:  ffff880231a98000 ffffffff818b4504 ffff88022daf6=
400 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff880231a97ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:37:48 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:37:48 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: wpa_supplicant  D ffff88023bc956c0     0   573  =
    1 0x00000000
Dec 05 00:37:48 al kernel:  ffff8800aca2fa48 0000000000000086 ffff880232600=
c80 ffff88022d101900
Dec 05 00:37:48 al kernel:  ffff8800aca30000 ffffffff818b4504 ffff88022d101=
900 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8800aca2fa60 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffffa05c782b>] nl80211_pre_doit+0xeb/0x18=
0 [cfg80211]
Dec 05 00:37:48 al kernel:  [<ffffffff814af5a8>] genl_family_rcv_msg+0x1c8/=
0x3c0
Dec 05 00:37:48 al kernel:  [<ffffffff814af7a0>] ? genl_family_rcv_msg+0x3c=
0/0x3c0
Dec 05 00:37:48 al kernel:  [<ffffffff814af816>] genl_rcv_msg+0x76/0xb0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae844>] netlink_rcv_skb+0xa4/0xc0
Dec 05 00:37:48 al kernel:  [<ffffffff814af3c8>] genl_rcv+0x28/0x40
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:37:48 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:37:48 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:37:48 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: Qt bearer threa D ffff88023bd156c0     0  8292  =
 8222 0x00000000
Dec 05 00:37:48 al kernel:  ffff8800ac9bfc88 0000000000000086 ffff880232601=
900 ffff880214323200
Dec 05 00:37:48 al kernel:  ffff8800ac9c0000 ffffffff818b4504 ffff880214323=
200 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8800ac9bfca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:37:48 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:37:48 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ksysguardd      D ffff88023bc156c0     0  8310  =
 8272 0x00000000
Dec 05 00:37:48 al kernel:  ffff8800a6b67ce8 0000000000000082 ffffffff81812=
500 ffff880205e04b00
Dec 05 00:37:48 al kernel:  ffff8800a6b68000 ffffffff818b4504 ffff880205e04=
b00 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8800a6b67d00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:37:48 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:37:48 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:37:48 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:37:48 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: DNS Res~ver #11 D ffff88023bc956c0     0 22782  =
 8222 0x00000000
Dec 05 00:37:48 al kernel:  ffff88007bf9fc88 0000000000000086 ffff880232600=
c80 ffff88023270d780
Dec 05 00:37:48 al kernel:  ffff88007bfa0000 ffffffff818b4504 ffff88023270d=
780 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff88007bf9fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:37:48 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: kworker/1:1     D ffff88023bc956c0     0 22090  =
    2 0x00000000
Dec 05 00:37:48 al kernel: Workqueue: events rtl_work_func_t [r8152]
Dec 05 00:37:48 al kernel:  ffff8801d6f2fc38 0000000000000046 ffff880232600=
c80 ffff88021f7ee400
Dec 05 00:37:48 al kernel:  ffff8801d6f30000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:37:48 al kernel:  0000000000000000 ffff8801d6f2fc50 ffffffff8157a=
09a ffff880228935890
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff8138f321>] ? n_tty_receive_buf_common=
+0x131/0xca0
Dec 05 00:37:48 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:37:48 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa0a816a0>] rtl_work_func_t+0x70/0x410=
 [r8152]
Dec 05 00:37:48 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff81393468>] ? flush_to_ldisc+0xa8/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:37:48 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:37:48 al kernel:  [<ffffffff81579940>] ? __schedule+0x340/0xa60
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel: kworker/0:1     D 0000000000000000     0 22654  =
    2 0x00000000
Dec 05 00:37:48 al kernel: Workqueue: usb_hub_wq hub_event [usbcore]
Dec 05 00:37:48 al kernel:  ffff8800447f7ab0 0000000000000046 ffff8802327c6=
400 ffff8801d7e4a580
Dec 05 00:37:48 al kernel:  ffff8800447f8000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:37:48 al kernel:  0000000000000000 ffff8800447f7ac8 ffffffff8157a=
09a ffff880228935890
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:37:48 al kernel:  [<ffffffff813da963>] __device_release_driver+0x=
43/0x150
Dec 05 00:37:48 al kernel:  [<ffffffff813daa93>] device_release_driver+0x23=
/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff813da0f1>] bus_remove_device+0x101/0x=
170
Dec 05 00:37:48 al kernel:  [<ffffffff813d63c9>] device_del+0x139/0x260
Dec 05 00:37:48 al kernel:  [<ffffffffa0203f3f>] ? usb_remove_ep_devs+0x1f/=
0x30 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa01fcff9>] usb_disable_device+0x89/0x=
270 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa01f2ce2>] usb_disconnect+0x92/0x2b0 =
[usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa01f4eb7>] hub_event+0x737/0x1520 [us=
bcore]
Dec 05 00:37:48 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:37:48 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel: kworker/2:1     D ffff88023bd156c0     0 23024  =
    2 0x00000000
Dec 05 00:37:48 al kernel: Workqueue: ipv6_addrconf addrconf_verify_work
Dec 05 00:37:48 al kernel:  ffff8802057b3d58 0000000000000046 ffff880228897=
080 ffff880214112580
Dec 05 00:37:48 al kernel:  ffff8802057b4000 ffffffff818b4504 ffff880214112=
580 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8802057b3d70 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8152d23e>] addrconf_verify_work+0xe/0=
x20
Dec 05 00:37:48 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:37:48 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:37:48 al kernel:  [<ffffffff81579940>] ? __schedule+0x340/0xa60
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel: kworker/0:3     D ffff88023bc156c0     0 23025  =
    2 0x00000000
Dec 05 00:37:48 al kernel: Workqueue: pm pm_runtime_work
Dec 05 00:37:48 al kernel:  ffff88009685fb78 0000000000000046 ffff880205d6e=
400 ffff8802327c6400
Dec 05 00:37:48 al kernel:  ffff880096860000 000000010bc38465 ffff88009685f=
bb0 ffff88023bc0dc00
Dec 05 00:37:48 al kernel:  0000000000000001 ffff88009685fb90 ffffffff8157a=
09a ffff88023bc0dc00
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157ca35>] schedule_timeout+0x125/0x2=
40
Dec 05 00:37:48 al kernel:  [<ffffffff810dd6c0>] ? init_timer_key+0xb0/0xb0
Dec 05 00:37:48 al kernel:  [<ffffffff810b5915>] ? finish_wait+0x55/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff810de75d>] msleep+0x2d/0x40
Dec 05 00:37:48 al kernel:  [<ffffffff81479c37>] napi_disable+0x47/0x60
Dec 05 00:37:48 al kernel:  [<ffffffffa0a7ed30>] rtl8152_suspend+0xc0/0x1b0=
 [r8152]
Dec 05 00:37:48 al kernel:  [<ffffffffa01ff06a>] usb_suspend_both+0x9a/0x1d=
0 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa0200088>] usb_runtime_suspend+0x38/0=
x70 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa0200050>] ? usb_probe_interface+0x2d=
0/0x2d0 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffff813e4522>] __rpm_callback+0x32/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff813e45bf>] rpm_callback+0x5f/0x80
Dec 05 00:37:48 al kernel:  [<ffffffffa0200050>] ? usb_probe_interface+0x2d=
0/0x2d0 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffff813e4b1b>] rpm_suspend+0x12b/0x640
Dec 05 00:37:48 al kernel:  [<ffffffff813e624f>] pm_runtime_work+0x6f/0xb0
Dec 05 00:37:48 al kernel:  [<ffffffff8108cfeb>] process_one_work+0x14b/0x4=
40
Dec 05 00:37:48 al kernel:  [<ffffffff8108d328>] worker_thread+0x48/0x4a0
Dec 05 00:37:48 al kernel:  [<ffffffff81579940>] ? __schedule+0x340/0xa60
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff8108d2e0>] ? process_one_work+0x440/0=
x440
Dec 05 00:37:48 al kernel:  [<ffffffff81092e68>] kthread+0xd8/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel:  [<ffffffff8157de9f>] ret_from_fork+0x3f/0x70
Dec 05 00:37:48 al kernel:  [<ffffffff81092d90>] ? kthread_worker_fn+0x170/=
0x170
Dec 05 00:37:48 al kernel: ping            D 0000000000000000     0 23097  =
23091 0x00000002
Dec 05 00:37:48 al kernel:  ffff880037367ca8 0000000000000046 ffff8801d7e4a=
580 ffff8802327c5780
Dec 05 00:37:48 al kernel:  ffff880037368000 ffffffff818b4504 ffff8802327c5=
780 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff880037367cc0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff815583fd>] ip6mr_sk_done+0x2d/0xe0
Dec 05 00:37:48 al kernel:  [<ffffffff815437fd>] rawv6_close+0x1d/0x40
Dec 05 00:37:48 al kernel:  [<ffffffff814f258f>] inet_release+0x3f/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff81521290>] inet6_release+0x30/0x40
Dec 05 00:37:48 al kernel:  [<ffffffff8145f53f>] sock_release+0x1f/0x80
Dec 05 00:37:48 al kernel:  [<ffffffff8145f5b2>] sock_close+0x12/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff811d61dc>] __fput+0x9c/0x1f0
Dec 05 00:37:48 al kernel:  [<ffffffff811d636e>] ____fput+0xe/0x10
Dec 05 00:37:48 al kernel:  [<ffffffff81091173>] task_work_run+0x73/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff81077c85>] do_exit+0x395/0xb40
Dec 05 00:37:48 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff810784ab>] do_group_exit+0x3b/0xb0
Dec 05 00:37:48 al kernel:  [<ffffffff81078534>] SyS_exit_group+0x14/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ethtool         D 0000000000000003     0 23105  =
23099 0x00000000
Dec 05 00:37:48 al kernel:  ffff8800a6b53b28 0000000000000086 ffff880230ab8=
000 ffff88021f723200
Dec 05 00:37:48 al kernel:  ffff8800a6b54000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:37:48 al kernel:  0000000000000000 ffff8800a6b53b40 ffffffff8157a=
09a ffff880228935890
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:37:48 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:37:48 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:37:48 al kernel:  [<ffffffffa0a8042a>] rtl8152_get_settings+0x2a/=
0x80 [r8152]
Dec 05 00:37:48 al kernel:  [<ffffffff81480df7>] __ethtool_get_settings+0x6=
7/0xa0
Dec 05 00:37:48 al kernel:  [<ffffffff814827f7>] dev_ethtool+0x697/0x1da0
Dec 05 00:37:48 al kernel:  [<ffffffff81392fab>] ? tty_flip_buffer_push+0x2=
b/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff810b568d>] ? remove_wait_queue+0x4d/0=
x60
Dec 05 00:37:48 al kernel:  [<ffffffff8147603e>] ? dev_get_by_name_rcu+0x5e=
/0x80
Dec 05 00:37:48 al kernel:  [<ffffffff81494c42>] dev_ioctl+0x182/0x590
Dec 05 00:37:48 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8138a651>] ? tty_write+0x1c1/0x2d0
Dec 05 00:37:48 al kernel:  [<ffffffff8145e2f2>] sock_do_ioctl+0x42/0x50
Dec 05 00:37:48 al kernel:  [<ffffffff8145e7f2>] sock_ioctl+0x1d2/0x290
Dec 05 00:37:48 al kernel:  [<ffffffff811e64d5>] do_vfs_ioctl+0x295/0x480
Dec 05 00:37:48 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff811e6739>] SyS_ioctl+0x79/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ip              D ffff88023bc156c0     0 23119  =
23118 0x00000000
Dec 05 00:37:48 al kernel:  ffff8800a6bd7c88 0000000000000082 ffffffff81812=
500 ffff880214115780
Dec 05 00:37:48 al kernel:  ffff8800a6bd8000 ffffffff818b4504 ffff880214115=
780 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8800a6bd7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ip              D 0000000000000003     0 23138  =
22800 0x00000004
Dec 05 00:37:48 al kernel:  ffff88009e2bbc88 0000000000000082 ffff8800ad6a3=
e80 ffff88007c71be80
Dec 05 00:37:48 al kernel:  ffff88009e2bc000 ffffffff818b4504 ffff88007c71b=
e80 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff88009e2bbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ip              D ffff88023bc956c0     0 23148  =
23147 0x00000000
Dec 05 00:37:48 al kernel:  ffff88022893fc88 0000000000000082 ffff880232600=
c80 ffff880205d6b200
Dec 05 00:37:48 al kernel:  ffff880228940000 ffffffff818b4504 ffff880205d6b=
200 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff88022893fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: ip              D ffff88023bd956c0     0 23170  =
    1 0x00000004
Dec 05 00:37:48 al kernel:  ffff8801d74fbc88 0000000000000082 ffff880232602=
580 ffff880205d6d780
Dec 05 00:37:48 al kernel:  ffff8801d74fc000 ffffffff818b4504 ffff880205d6d=
780 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff8801d74fbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:37:48 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:48 al kernel: sudo            D 0000000000000003     0 23270  =
 9785 0x00000000
Dec 05 00:37:48 al kernel:  ffff88023108bc88 0000000000000082 ffff880230ab8=
000 ffff8802141f6400
Dec 05 00:37:48 al kernel:  ffff88023108c000 ffffffff818b4504 ffff8802141f6=
400 00000000ffffffff
Dec 05 00:37:48 al kernel:  ffffffff818b4508 ffff88023108bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:37:48 al kernel: Call Trace:
Dec 05 00:37:48 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:37:48 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:37:48 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:37:48 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:37:48 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:37:48 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:37:48 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:37:48 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:37:48 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:37:48 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:37:48 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:37:48 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:37:52 al NetworkManager[441]: <warn>  Could not get scan request =
result: Timeout was reached
Dec 05 00:38:42 al kernel: sysrq: SysRq : Show backtrace of all active CPUs
Dec 05 00:38:42 al kernel: Sending NMI to all CPUs:
Dec 05 00:38:42 al kernel: NMI backtrace for cpu 0
Dec 05 00:38:42 al kernel: CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:38:42 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:38:42 al kernel: task: ffffffff81812500 ti: ffffffff81800000 task=
=2Eti: ffffffff81800000
Dec 05 00:38:42 al kernel: RIP: 0010:[<ffffffff812c7aa0>]  [<ffffffff812c7a=
a0>] __delay+0x0/0x20
Dec 05 00:38:42 al kernel: RSP: 0018:ffff88023bc03c00  EFLAGS: 00000817
Dec 05 00:38:42 al kernel: RAX: 0000000027c31860 RBX: 0000000000002710 RCX:=
 0000000002a47fa7
Dec 05 00:38:42 al kernel: RDX: 0000000000289719 RSI: 0000000000000080 RDI:=
 000000000028971a
Dec 05 00:38:42 al kernel: RBP: ffff88023bc03c08 R08: 000000000000000a R09:=
 0000000000003562
Dec 05 00:38:42 al kernel: R10: 0000000000000026 R11: 0000000000003562 R12:=
 0000000000000001
Dec 05 00:38:42 al kernel: R13: ffffffff81051e30 R14: ffffffff81897240 R15:=
 0000000000000001
Dec 05 00:38:42 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc00000(=
0000) knlGS:0000000000000000
Dec 05 00:38:42 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:38:42 al kernel: CR2: 00007f301760f000 CR3: 000000000180b000 CR4:=
 00000000000006f0
Dec 05 00:38:42 al kernel: Stack:
Dec 05 00:38:42 al kernel:  ffffffff812c7aed ffff88023bc03c50 ffffffff812c0=
34a ffff880200000010
Dec 05 00:38:42 al kernel:  ffff88023bc03c80 000000000000006c 0000000000000=
004 0000000000000001
Dec 05 00:38:42 al kernel:  ffffffff81897240 0000000000000001 ffff88023bc03=
c60 ffffffff81051ea9
Dec 05 00:38:42 al kernel: Call Trace:
Dec 05 00:38:42 al kernel:  <IRQ> =01d [<ffffffff812c7aed>] ? __const_udela=
y+0x2d/0x30
Dec 05 00:38:42 al kernel:  [<ffffffff812c034a>] nmi_trigger_all_cpu_backtr=
ace+0xfa/0x2a0
Dec 05 00:38:42 al kernel:  [<ffffffff81051ea9>] arch_trigger_all_cpu_backt=
race+0x19/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff813956e3>] sysrq_handle_showallcpus+0=
x13/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff81395d8f>] __handle_sysrq+0xef/0x140
Dec 05 00:38:42 al kernel:  [<ffffffff81396193>] sysrq_filter+0x383/0x3d0
Dec 05 00:38:42 al kernel:  [<ffffffff81415a4a>] input_to_handler+0x5a/0x100
Dec 05 00:38:42 al kernel:  [<ffffffff81417659>] input_pass_values.part.1+0=
x179/0x190
Dec 05 00:38:42 al kernel:  [<ffffffff81417983>] input_handle_event+0xc3/0x=
4e0
Dec 05 00:38:42 al kernel:  [<ffffffff81417df8>] input_event+0x58/0x80
Dec 05 00:38:42 al kernel:  [<ffffffffa030c892>] atkbd_interrupt+0x4d2/0x7f=
0 [atkbd]
Dec 05 00:38:42 al kernel:  [<ffffffffa0062ec6>] serio_interrupt+0x46/0x90 =
[serio]
Dec 05 00:38:42 al kernel:  [<ffffffffa00a3662>] i8042_interrupt+0x1f2/0x3c=
0 [i8042]
Dec 05 00:38:42 al kernel:  [<ffffffff81093c66>] ? raw_notifier_call_chain+=
0x16/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810cce59>] handle_irq_event_percpu+0x=
39/0x1b0
Dec 05 00:38:42 al kernel:  [<ffffffff810cd010>] handle_irq_event+0x40/0x60
Dec 05 00:38:42 al kernel:  [<ffffffff810d002b>] handle_edge_irq+0xab/0x130
Dec 05 00:38:42 al kernel:  [<ffffffff81018c8a>] handle_irq+0x1a/0x30
Dec 05 00:38:42 al kernel:  [<ffffffff8158082b>] do_IRQ+0x4b/0xd0
Dec 05 00:38:42 al kernel:  [<ffffffff8157e602>] common_interrupt+0x82/0x82
Dec 05 00:38:42 al kernel:  <EOI> =01d [<ffffffff814363d1>] ? cpuidle_enter=
_state+0x121/0x290
Dec 05 00:38:42 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:38:42 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:38:42 al kernel:  [<ffffffff81571b79>] rest_init+0x89/0x90
Dec 05 00:38:42 al kernel:  [<ffffffff81904013>] start_kernel+0x483/0x4a4
Dec 05 00:38:42 al kernel:  [<ffffffff81903120>] ? early_idt_handler_array+=
0x120/0x120
Dec 05 00:38:42 al kernel:  [<ffffffff81903339>] x86_64_start_reservations+=
0x2a/0x2c
Dec 05 00:38:42 al kernel:  [<ffffffff81903485>] x86_64_start_kernel+0x14a/=
0x16d
Dec 05 00:38:42 al kernel: Code: d1 0f 01 fb 0f ae e8 0f 31 48 c1 e2 20 48 =
09 d0 48 89 c2 48 29 f2 48 39 d7 77 b9 5b 41 5c 5d c3 90 66 2e 0f 1f 84 00 =
00 00 00 00 <66> 66 66 66 90 55 48 89 e5 ff 15 e9 4f 5c 00 5d c3 0f 1f 44 0=
0=20
Dec 05 00:38:42 al kernel: NMI backtrace for cpu 1
Dec 05 00:38:42 al kernel: CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:38:42 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:38:42 al kernel: task: ffff880232600c80 ti: ffff880232608000 task=
=2Eti: ffff880232608000
Dec 05 00:38:42 al kernel: RIP: 0010:[<ffffffff81437b1d>]  [<ffffffff81437b=
1d>] menu_select+0x10d/0x3f0
Dec 05 00:38:42 al kernel: RSP: 0018:ffff88023260be60  EFLAGS: 00000002
Dec 05 00:38:42 al kernel: RAX: 0000000000002d43 RBX: ffff88023bc92844 RCX:=
 ffff88023bc92844
Dec 05 00:38:42 al kernel: RDX: 0000000000007c8d RSI: ffff88023bc92844 RDI:=
 0000000000007c8c
Dec 05 00:38:42 al kernel: RBP: ffff88023260bec0 R08: 0000000000048af7 R09:=
 000000000000001c
Dec 05 00:38:42 al kernel: R10: 000000000000235a R11: 0000000000000000 R12:=
 0000000000002bfb
Dec 05 00:38:42 al kernel: R13: 0000000000000000 R14: 0000000000000000 R15:=
 ffff88023bc92864
Dec 05 00:38:42 al kernel: FS:  0000000000000000(0000) GS:ffff88023bc80000(=
0000) knlGS:0000000000000000
Dec 05 00:38:42 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:38:42 al kernel: CR2: 00007f516b76a3d0 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:38:42 al kernel: Stack:
Dec 05 00:38:42 al kernel:  ffff88023bc9cb00 77359400814363af ffff88023bc92=
800 ffffffff818919a0
Dec 05 00:38:42 al kernel:  0000000000000000 0000000000000000 3e6b2308d22ec=
f91 ffff88023260c000
Dec 05 00:38:42 al kernel:  ffffffff818e0190 ffff88023bc9cb00 ffff880232608=
000 ffffffff818919a0
Dec 05 00:38:42 al kernel: Call Trace:
Dec 05 00:38:42 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:38:42 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:38:42 al kernel: Code: c3 44 4c 8d 78 64 48 89 de 48 89 d9 45 31 =
f6 45 31 ed 45 31 db 8b 11 39 fa 77 10 89 d0 41 83 c5 01 49 01 c3 41 39 d6 =
44 0f 42 f2 <48> 83 c1 04 4c 39 f9 75 e1 41 83 fd 08 0f 84 a7 01 00 00 49 6=
3=20
Dec 05 00:38:42 al kernel: NMI backtrace for cpu 2
Dec 05 00:38:42 al kernel: CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:38:42 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:38:42 al kernel: task: ffff880232601900 ti: ffff88023260c000 task=
=2Eti: ffff88023260c000
Dec 05 00:38:42 al kernel: RIP: 0010:[<ffffffff81339a9e>]  [<ffffffff81339a=
9e>] intel_idle+0xbe/0x120
Dec 05 00:38:42 al kernel: RSP: 0018:ffff88023260fe40  EFLAGS: 00000046
Dec 05 00:38:42 al kernel: RAX: 0000000000000020 RBX: 0000000000000008 RCX:=
 0000000000000001
Dec 05 00:38:42 al kernel: RDX: 0000000000000000 RSI: ffff880232610000 RDI:=
 0000000000000002
Dec 05 00:38:42 al kernel: RBP: ffff88023260fe60 R08: 00000d16892dc648 R09:=
 0000000000000018
Dec 05 00:38:42 al kernel: R10: 0000000000000304 R11: 0000000000005a1e R12:=
 0000000000000020
Dec 05 00:38:42 al kernel: R13: 0000000000000003 R14: 0000000000000004 R15:=
 ffffffff81891b38
Dec 05 00:38:42 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd00000(=
0000) knlGS:0000000000000000
Dec 05 00:38:42 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:38:42 al kernel: CR2: 00007f06f9f1c000 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:38:42 al kernel: Stack:
Dec 05 00:38:42 al kernel:  0000000000000004 ffffffff818919a0 ffff88023bd1c=
b00 000256a8171311b7
Dec 05 00:38:42 al kernel:  ffff88023260fea8 ffffffff81436397 000000003bd12=
800 ffffffff818919a0
Dec 05 00:38:42 al kernel:  ffff880232610000 ffffffff818e0190 ffff88023bd1c=
b00 ffff88023260c000
Dec 05 00:38:42 al kernel: Call Trace:
Dec 05 00:38:42 al kernel:  [<ffffffff81436397>] cpuidle_enter_state+0xe7/0=
x290
Dec 05 00:38:42 al kernel:  [<ffffffff81436577>] cpuidle_enter+0x17/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b60f2>] call_cpuidle+0x32/0x60
Dec 05 00:38:42 al kernel:  [<ffffffff81436553>] ? cpuidle_select+0x13/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b63b2>] cpu_startup_entry+0x292/0x=
370
Dec 05 00:38:42 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:38:42 al kernel: Code: 48 8b 34 25 c4 2b 01 00 48 89 d1 48 8d 86 =
08 c0 ff ff 0f 01 c8 48 8b 86 08 c0 ff ff a8 08 75 0b b9 01 00 00 00 4c 89 =
e0 0f 01 c9 <65> 48 8b 04 25 c4 2b 01 00 f0 80 a0 0a c0 ff ff df 0f ae f0 4=
8=20
Dec 05 00:38:42 al kernel: NMI backtrace for cpu 3
Dec 05 00:38:42 al kernel: CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        =
   O    4.3.0-1-ARCH #1
Dec 05 00:38:42 al kernel: Hardware name: CLEVO CO.                        =
B7130                           /B7130                           , BIOS 6.0=
0 08/27/2010
Dec 05 00:38:42 al kernel: task: ffff880232602580 ti: ffff880232610000 task=
=2Eti: ffff880232610000
Dec 05 00:38:42 al kernel: RIP: 0010:[<ffffffff81437b04>]  [<ffffffff81437b=
04>] menu_select+0xf4/0x3f0
Dec 05 00:38:42 al kernel: RSP: 0018:ffff880232613e60  EFLAGS: 00000046
Dec 05 00:38:42 al kernel: RAX: 0000000000002d43 RBX: ffff88023bd92844 RCX:=
 ffff88023bd92844
Dec 05 00:38:42 al kernel: RDX: 0000000000010f92 RSI: ffff88023bd92844 RDI:=
 0000000000007c8c
Dec 05 00:38:42 al kernel: RBP: ffff880232613ec0 R08: 0000000000052fc0 R09:=
 000000000000001c
Dec 05 00:38:42 al kernel: R10: ffffffff818e01a0 R11: 00000000000133e3 R12:=
 0000000000002bfb
Dec 05 00:38:42 al kernel: R13: 0000000000000000 R14: 0000000000000000 R15:=
 ffff88023bd92864
Dec 05 00:38:42 al kernel: FS:  0000000000000000(0000) GS:ffff88023bd80000(=
0000) knlGS:0000000000000000
Dec 05 00:38:42 al kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec 05 00:38:42 al kernel: CR2: 00007f5147d76000 CR3: 000000000180b000 CR4:=
 00000000000006e0
Dec 05 00:38:42 al kernel: Stack:
Dec 05 00:38:42 al kernel:  ffff88023bd9cb00 77359400814363af ffff88023bd92=
800 ffffffff818919a0
Dec 05 00:38:42 al kernel:  0000000000000000 0000000000000000 f8637a1d6e905=
864 ffff880232614000
Dec 05 00:38:42 al kernel:  ffffffff818e0190 ffff88023bd9cb00 ffff880232610=
000 ffffffff818919a0
Dec 05 00:38:42 al kernel: Call Trace:
Dec 05 00:38:42 al kernel:  [<ffffffff81436553>] cpuidle_select+0x13/0x20
Dec 05 00:38:42 al kernel:  [<ffffffff810b63a5>] cpu_startup_entry+0x285/0x=
370
Dec 05 00:38:42 al kernel:  [<ffffffff8104d97b>] start_secondary+0x15b/0x190
Dec 05 00:38:42 al kernel: Code: 54 93 14 48 0f af c2 48 05 00 10 00 00 48 =
c1 e8 0d 89 43 0c 48 89 d8 48 83 c3 44 4c 8d 78 64 48 89 de 48 89 d9 45 31 =
f6 45 31 ed <45> 31 db 8b 11 39 fa 77 10 89 d0 41 83 c5 01 49 01 c3 41 39 d=
6=20
Dec 05 00:38:54 al NetworkManager[441]: <warn>  Could not get scan request =
result: Timeout was reached

[.. other attempts like terminating/killing all processes, SAK, etc. ..]

Dec 05 00:42:09 al systemd-logind[23536]: Suspend key pressed.
Dec 05 00:42:09 al systemd-logind[23536]: Suspending...
Dec 05 00:42:13 al systemd-logind[23536]: Suspend key pressed.
Dec 05 00:42:14 al systemd-logind[23536]: Delay lock is active (UID 0/root,=
 PID 441/NetworkManager) but inhibitor timeout is reached.
Dec 05 00:42:14 al systemd[1]: Starting Flush collectd daemon before sleep =
and on resume...
Dec 05 00:42:14 al systemd[1]: System statistics collection daemon is not a=
ctive.
Dec 05 00:42:14 al systemd[1]: Dependency failed for Flush collectd daemon =
before sleep and on resume.
Dec 05 00:42:14 al systemd[1]: collectd-flush.service: Job collectd-flush.s=
ervice/start failed with result 'dependency'.
Dec 05 00:42:14 al systemd[1]: Reached target Sleep.
Dec 05 00:42:14 al systemd[1]: Starting Suspend...
Dec 05 00:42:14 al systemd-sleep[23583]: Suspending system...
Dec 05 00:42:14 al echo[23582]: Flushing collectd on sleep...
Dec 05 00:42:15 al kernel: PM: Syncing filesystems ... done.
Dec 05 00:42:15 al kernel: PM: Preparing system for sleep (mem)
Dec 05 00:42:15 al kernel: bbswitch: enabling discrete graphics
Dec 05 00:42:36 al kernel: Freezing user space processes ...=20
Dec 05 00:42:36 al kernel: sysrq: SysRq :=20
Dec 05 00:42:36 al kernel: Emergency Sync
Dec 05 00:42:36 al kernel: Emergency Sync complete
Dec 05 00:42:36 al kernel:=20
Dec 05 00:42:36 al kernel: Freezing of tasks failed after 20.005 seconds (1=
9 tasks refusing to freeze, wq_busy=3D0):
Dec 05 00:42:36 al kernel: NetworkManager  D 0000000000000002     0   441  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88022db43b98 0000000000000082 ffff88009e1cf=
080 ffff880037605780
Dec 05 00:42:36 al kernel:  ffff88022db44000 ffffffff818b4504 ffff880037605=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88022db43bb0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:42:36 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:36 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:42:36 al kernel:  [<ffffffff8146151d>] ? SyS_sendto+0x15d/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811f0487>] ? __fget+0x77/0xb0
Dec 05 00:42:36 al kernel:  [<ffffffff811f0525>] ? __fget_light+0x25/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: collectd        D ffff88023bc156c0     0   552  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800ac99fce8 0000000000000086 ffffffff81812=
500 ffff880230408c80
Dec 05 00:42:36 al kernel:  ffff8800ac9a0000 ffffffff818b4504 ffff880230408=
c80 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800ac99fd00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:42:36 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:42:36 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:42:36 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:42:36 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:42:36 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:42:36 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ntpd            D ffff88023bc956c0     0   518  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff880231a97c88 0000000000000082 ffff880232600=
c80 ffff88022daf6400
Dec 05 00:42:36 al kernel:  ffff880231a98000 ffffffff818b4504 ffff88022daf6=
400 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff880231a97ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:36 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: wpa_supplicant  D ffff88023bc956c0     0   573  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800aca2fa48 0000000000000086 ffff880232600=
c80 ffff88022d101900
Dec 05 00:42:36 al kernel:  ffff8800aca30000 ffffffff818b4504 ffff88022d101=
900 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800aca2fa60 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffffa05c782b>] nl80211_pre_doit+0xeb/0x18=
0 [cfg80211]
Dec 05 00:42:36 al kernel:  [<ffffffff814af5a8>] genl_family_rcv_msg+0x1c8/=
0x3c0
Dec 05 00:42:36 al kernel:  [<ffffffff814af7a0>] ? genl_family_rcv_msg+0x3c=
0/0x3c0
Dec 05 00:42:36 al kernel:  [<ffffffff814af816>] genl_rcv_msg+0x76/0xb0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae844>] netlink_rcv_skb+0xa4/0xc0
Dec 05 00:42:36 al kernel:  [<ffffffff814af3c8>] genl_rcv+0x28/0x40
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:42:36 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:36 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:42:36 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: Qt bearer threa D ffff88023bd156c0     0  8292  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800ac9bfc88 0000000000000086 ffff880232601=
900 ffff880214323200
Dec 05 00:42:36 al kernel:  ffff8800ac9c0000 ffffffff818b4504 ffff880214323=
200 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800ac9bfca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:36 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: pulseaudio      D 0000000000000000     0  8305  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800aca93c88 0000000000000082 ffff880037440=
000 ffff880214323e80
Dec 05 00:42:36 al kernel:  ffff8800aca94000 ffffffff818b4504 ffff880214323=
e80 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800aca93ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:36 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ksysguardd      D ffff88023bc156c0     0  8310  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800a6b67ce8 0000000000000082 ffffffff81812=
500 ffff880205e04b00
Dec 05 00:42:36 al kernel:  ffff8800a6b68000 ffffffff818b4504 ffff880205e04=
b00 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800a6b67d00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:42:36 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:42:36 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:42:36 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:42:36 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:42:36 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:42:36 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: DNS Res~ver #11 D ffff88023bc956c0     0 22782  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88007bf9fc88 0000000000000086 ffff880232600=
c80 ffff88023270d780
Dec 05 00:42:36 al kernel:  ffff88007bfa0000 ffffffff818b4504 ffff88023270d=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88007bf9fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ping            D 0000000000000000     0 23097  =
    1 0x00000006
Dec 05 00:42:36 al kernel:  ffff880037367ca8 0000000000000046 ffff8801d7e4a=
580 ffff8802327c5780
Dec 05 00:42:36 al kernel:  ffff880037368000 ffffffff818b4504 ffff8802327c5=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff880037367cc0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff815583fd>] ip6mr_sk_done+0x2d/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff815437fd>] rawv6_close+0x1d/0x40
Dec 05 00:42:36 al kernel:  [<ffffffff814f258f>] inet_release+0x3f/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff81521290>] inet6_release+0x30/0x40
Dec 05 00:42:36 al kernel:  [<ffffffff8145f53f>] sock_release+0x1f/0x80
Dec 05 00:42:36 al kernel:  [<ffffffff8145f5b2>] sock_close+0x12/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff811d61dc>] __fput+0x9c/0x1f0
Dec 05 00:42:36 al kernel:  [<ffffffff811d636e>] ____fput+0xe/0x10
Dec 05 00:42:36 al kernel:  [<ffffffff81091173>] task_work_run+0x73/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff81077c85>] do_exit+0x395/0xb40
Dec 05 00:42:36 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff810784ab>] do_group_exit+0x3b/0xb0
Dec 05 00:42:36 al kernel:  [<ffffffff81078534>] SyS_exit_group+0x14/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ethtool         D 0000000000000003     0 23105  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800a6b53b28 0000000000000086 ffff880230ab8=
000 ffff88021f723200
Dec 05 00:42:36 al kernel:  ffff8800a6b54000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:42:36 al kernel:  0000000000000000 ffff8800a6b53b40 ffffffff8157a=
09a ffff880228935890
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:42:36 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:42:36 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:42:36 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:42:36 al kernel:  [<ffffffffa0a8042a>] rtl8152_get_settings+0x2a/=
0x80 [r8152]
Dec 05 00:42:36 al kernel:  [<ffffffff81480df7>] __ethtool_get_settings+0x6=
7/0xa0
Dec 05 00:42:36 al kernel:  [<ffffffff814827f7>] dev_ethtool+0x697/0x1da0
Dec 05 00:42:36 al kernel:  [<ffffffff81392fab>] ? tty_flip_buffer_push+0x2=
b/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff810b568d>] ? remove_wait_queue+0x4d/0=
x60
Dec 05 00:42:36 al kernel:  [<ffffffff8147603e>] ? dev_get_by_name_rcu+0x5e=
/0x80
Dec 05 00:42:36 al kernel:  [<ffffffff81494c42>] dev_ioctl+0x182/0x590
Dec 05 00:42:36 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8138a651>] ? tty_write+0x1c1/0x2d0
Dec 05 00:42:36 al kernel:  [<ffffffff8145e2f2>] sock_do_ioctl+0x42/0x50
Dec 05 00:42:36 al kernel:  [<ffffffff8145e7f2>] sock_ioctl+0x1d2/0x290
Dec 05 00:42:36 al kernel:  [<ffffffff811e64d5>] do_vfs_ioctl+0x295/0x480
Dec 05 00:42:36 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff811e6739>] SyS_ioctl+0x79/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bc156c0     0 23119  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800a6bd7c88 0000000000000082 ffffffff81812=
500 ffff880214115780
Dec 05 00:42:36 al kernel:  ffff8800a6bd8000 ffffffff818b4504 ffff880214115=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800a6bd7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D 0000000000000003     0 23138  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88009e2bbc88 0000000000000082 ffff8800ad6a3=
e80 ffff88007c71be80
Dec 05 00:42:36 al kernel:  ffff88009e2bc000 ffffffff818b4504 ffff88007c71b=
e80 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88009e2bbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bc956c0     0 23148  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88022893fc88 0000000000000082 ffff880232600=
c80 ffff880205d6b200
Dec 05 00:42:36 al kernel:  ffff880228940000 ffffffff818b4504 ffff880205d6b=
200 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88022893fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bd956c0     0 23170  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8801d74fbc88 0000000000000082 ffff880232602=
580 ffff880205d6d780
Dec 05 00:42:36 al kernel:  ffff8801d74fc000 ffffffff818b4504 ffff880205d6d=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8801d74fbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: sudo            D 0000000000000003     0 23270  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88023108bc88 0000000000000082 ffff880230ab8=
000 ffff8802141f6400
Dec 05 00:42:36 al kernel:  ffff88023108c000 ffffffff818b4504 ffff8802141f6=
400 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88023108bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:36 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bd156c0     0 23407  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8802143d7c88 0000000000000082 ffff880232601=
900 ffff88022daf4b00
Dec 05 00:42:36 al kernel:  ffff8802143d8000 ffffffff818b4504 ffff88022daf4=
b00 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8802143d7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: sshd            D ffff88023bc956c0     0 23454  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800aca57c88 0000000000000086 ffff880232600=
c80 ffff8801d7e48000
Dec 05 00:42:36 al kernel:  ffff8800aca58000 ffffffff818b4504 ffff8801d7e48=
000 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800aca57ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:36 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bc156c0     0 23488  =
    1 0x00000004
Dec 05 00:42:36 al kernel:  ffff88021b45bc88 0000000000000082 ffffffff81812=
500 ffff8801d7e4d780
Dec 05 00:42:36 al kernel:  ffff88021b45c000 ffffffff818b4504 ffff8801d7e4d=
780 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff88021b45bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel: ip              D ffff88023bc956c0     0 23579  =
23578 0x00000004
Dec 05 00:42:36 al kernel:  ffff8800ad60bc88 0000000000000086 ffff880232600=
c80 ffff88009e1c8000
Dec 05 00:42:36 al kernel:  ffff8800ad60c000 ffffffff818b4504 ffff88009e1c8=
000 00000000ffffffff
Dec 05 00:42:36 al kernel:  ffffffff818b4508 ffff8800ad60bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:36 al kernel: Call Trace:
Dec 05 00:42:36 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:36 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:36 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:36 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:36 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:36 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:36 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:36 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:36 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:36 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:36 al kernel:=20
Dec 05 00:42:36 al kernel: Restarting tasks ... done.
Dec 05 00:42:36 al kernel: video LNXVIDEO:00: Restoring backlight state
Dec 05 00:42:36 al kernel: video LNXVIDEO:01: Restoring backlight state
Dec 05 00:42:36 al kernel: bbswitch: disabling discrete graphics
Dec 05 00:42:36 al kernel: ACPI Warning: \_SB_.PCI0.P0P2.PEGP._DSM: Argumen=
t #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150818/nsar=
guments-95)
Dec 05 00:42:36 al kernel: PM: Syncing filesystems ... done.
Dec 05 00:42:36 al kernel: PM: Preparing system for sleep (freeze)
Dec 05 00:42:36 al kernel: bbswitch: enabling discrete graphics
Dec 05 00:42:57 al kernel: Freezing user space processes ...=20
Dec 05 00:42:57 al kernel: Freezing of tasks failed after 20.009 seconds (1=
9 tasks refusing to freeze, wq_busy=3D0):
Dec 05 00:42:57 al kernel: NetworkManager  D 0000000000000002     0   441  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88022db43b98 0000000000000082 ffff88009e1cf=
080 ffff880037605780
Dec 05 00:42:57 al kernel:  ffff88022db44000 ffffffff818b4504 ffff880037605=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88022db43bb0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:42:57 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:57 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:42:57 al kernel:  [<ffffffff8146151d>] ? SyS_sendto+0x15d/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811f0487>] ? __fget+0x77/0xb0
Dec 05 00:42:57 al kernel:  [<ffffffff811f0525>] ? __fget_light+0x25/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: collectd        D ffff88023bc156c0     0   552  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800ac99fce8 0000000000000086 ffffffff81812=
500 ffff880230408c80
Dec 05 00:42:57 al kernel:  ffff8800ac9a0000 ffffffff818b4504 ffff880230408=
c80 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800ac99fd00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:42:57 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:42:57 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:42:57 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:42:57 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:42:57 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:42:57 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ntpd            D ffff88023bc956c0     0   518  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff880231a97c88 0000000000000082 ffff880232600=
c80 ffff88022daf6400
Dec 05 00:42:57 al kernel:  ffff880231a98000 ffffffff818b4504 ffff88022daf6=
400 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff880231a97ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:57 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: wpa_supplicant  D ffff88023bc956c0     0   573  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800aca2fa48 0000000000000086 ffff880232600=
c80 ffff88022d101900
Dec 05 00:42:57 al kernel:  ffff8800aca30000 ffffffff818b4504 ffff88022d101=
900 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800aca2fa60 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffffa05c782b>] nl80211_pre_doit+0xeb/0x18=
0 [cfg80211]
Dec 05 00:42:57 al kernel:  [<ffffffff814af5a8>] genl_family_rcv_msg+0x1c8/=
0x3c0
Dec 05 00:42:57 al kernel:  [<ffffffff814af7a0>] ? genl_family_rcv_msg+0x3c=
0/0x3c0
Dec 05 00:42:57 al kernel:  [<ffffffff814af816>] genl_rcv_msg+0x76/0xb0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae844>] netlink_rcv_skb+0xa4/0xc0
Dec 05 00:42:57 al kernel:  [<ffffffff814af3c8>] genl_rcv+0x28/0x40
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460815>] ___sys_sendmsg+0x295/0x2b0
Dec 05 00:42:57 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:57 al kernel:  [<ffffffff8118ba98>] ? handle_mm_fault+0xb38/0x=
18a0
Dec 05 00:42:57 al kernel:  [<ffffffff81461971>] __sys_sendmsg+0x51/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff814619c2>] SyS_sendmsg+0x12/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: Qt bearer threa D ffff88023bd156c0     0  8292  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800ac9bfc88 0000000000000086 ffff880232601=
900 ffff880214323200
Dec 05 00:42:57 al kernel:  ffff8800ac9c0000 ffffffff818b4504 ffff880214323=
200 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800ac9bfca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:57 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: pulseaudio      D 0000000000000000     0  8305  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800aca93c88 0000000000000082 ffff880037440=
000 ffff880214323e80
Dec 05 00:42:57 al kernel:  ffff8800aca94000 ffffffff818b4504 ffff880214323=
e80 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800aca93ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:57 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ksysguardd      D ffff88023bc156c0     0  8310  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800a6b67ce8 0000000000000082 ffffffff81812=
500 ffff880205e04b00
Dec 05 00:42:57 al kernel:  ffff8800a6b68000 ffffffff818b4504 ffff880205e04=
b00 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800a6b67d00 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8156856b>] wireless_dev_seq_start+0x1=
b/0x70
Dec 05 00:42:57 al kernel:  [<ffffffff811f6ca8>] seq_read+0x168/0x390
Dec 05 00:42:57 al kernel:  [<ffffffff8123c372>] proc_reg_read+0x42/0x70
Dec 05 00:42:57 al kernel:  [<ffffffff811d3f17>] __vfs_read+0x37/0x100
Dec 05 00:42:57 al kernel:  [<ffffffff812762ee>] ? security_file_permission=
+0xae/0xc0
Dec 05 00:42:57 al kernel:  [<ffffffff811d47d3>] vfs_read+0x83/0x120
Dec 05 00:42:57 al kernel:  [<ffffffff811d5535>] SyS_read+0x55/0xc0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: DNS Res~ver #11 D ffff88023bc956c0     0 22782  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88007bf9fc88 0000000000000086 ffff880232600=
c80 ffff88023270d780
Dec 05 00:42:57 al kernel:  ffff88007bfa0000 ffffffff818b4504 ffff88023270d=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88007bf9fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff810ac614>] ? should_numa_migrate_memo=
ry+0x54/0x130
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612aa>] ? SyS_getsockname+0xaa/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ping            D 0000000000000000     0 23097  =
    1 0x00000006
Dec 05 00:42:57 al kernel:  ffff880037367ca8 0000000000000046 ffff8801d7e4a=
580 ffff8802327c5780
Dec 05 00:42:57 al kernel:  ffff880037368000 ffffffff818b4504 ffff8802327c5=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff880037367cc0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148b535>] rtnl_lock+0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff815583fd>] ip6mr_sk_done+0x2d/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff815437fd>] rawv6_close+0x1d/0x40
Dec 05 00:42:57 al kernel:  [<ffffffff814f258f>] inet_release+0x3f/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff81521290>] inet6_release+0x30/0x40
Dec 05 00:42:57 al kernel:  [<ffffffff8145f53f>] sock_release+0x1f/0x80
Dec 05 00:42:57 al kernel:  [<ffffffff8145f5b2>] sock_close+0x12/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff811d61dc>] __fput+0x9c/0x1f0
Dec 05 00:42:57 al kernel:  [<ffffffff811d636e>] ____fput+0xe/0x10
Dec 05 00:42:57 al kernel:  [<ffffffff81091173>] task_work_run+0x73/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff81077c85>] do_exit+0x395/0xb40
Dec 05 00:42:57 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff810784ab>] do_group_exit+0x3b/0xb0
Dec 05 00:42:57 al kernel:  [<ffffffff81078534>] SyS_exit_group+0x14/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ethtool         D 0000000000000003     0 23105  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800a6b53b28 0000000000000086 ffff880230ab8=
000 ffff88021f723200
Dec 05 00:42:57 al kernel:  ffff8800a6b54000 ffff880228935940 ffff880228935=
a00 0000000000000000
Dec 05 00:42:57 al kernel:  0000000000000000 ffff8800a6b53b40 ffffffff8157a=
09a ffff880228935890
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff813e55e2>] rpm_resume+0x1e2/0x690
Dec 05 00:42:57 al kernel:  [<ffffffff810b5db0>] ? wake_atomic_t_function+0=
x60/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff813e5728>] rpm_resume+0x328/0x690
Dec 05 00:42:57 al kernel:  [<ffffffff813e5acf>] __pm_runtime_resume+0x3f/0=
x60
Dec 05 00:42:57 al kernel:  [<ffffffffa01fed62>] usb_autopm_get_interface+0=
x22/0x60 [usbcore]
Dec 05 00:42:57 al kernel:  [<ffffffffa0a8042a>] rtl8152_get_settings+0x2a/=
0x80 [r8152]
Dec 05 00:42:57 al kernel:  [<ffffffff81480df7>] __ethtool_get_settings+0x6=
7/0xa0
Dec 05 00:42:57 al kernel:  [<ffffffff814827f7>] dev_ethtool+0x697/0x1da0
Dec 05 00:42:57 al kernel:  [<ffffffff81392fab>] ? tty_flip_buffer_push+0x2=
b/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff810b568d>] ? remove_wait_queue+0x4d/0=
x60
Dec 05 00:42:57 al kernel:  [<ffffffff8147603e>] ? dev_get_by_name_rcu+0x5e=
/0x80
Dec 05 00:42:57 al kernel:  [<ffffffff81494c42>] dev_ioctl+0x182/0x590
Dec 05 00:42:57 al kernel:  [<ffffffff81392226>] ? tty_ldisc_deref+0x16/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8138a651>] ? tty_write+0x1c1/0x2d0
Dec 05 00:42:57 al kernel:  [<ffffffff8145e2f2>] sock_do_ioctl+0x42/0x50
Dec 05 00:42:57 al kernel:  [<ffffffff8145e7f2>] sock_ioctl+0x1d2/0x290
Dec 05 00:42:57 al kernel:  [<ffffffff811e64d5>] do_vfs_ioctl+0x295/0x480
Dec 05 00:42:57 al kernel:  [<ffffffff811d49bf>] ? vfs_write+0x14f/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff811e6739>] SyS_ioctl+0x79/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bc156c0     0 23119  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800a6bd7c88 0000000000000082 ffffffff81812=
500 ffff880214115780
Dec 05 00:42:57 al kernel:  ffff8800a6bd8000 ffffffff818b4504 ffff880214115=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800a6bd7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D 0000000000000003     0 23138  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88009e2bbc88 0000000000000082 ffff8800ad6a3=
e80 ffff88007c71be80
Dec 05 00:42:57 al kernel:  ffff88009e2bc000 ffffffff818b4504 ffff88007c71b=
e80 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88009e2bbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bc956c0     0 23148  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88022893fc88 0000000000000082 ffff880232600=
c80 ffff880205d6b200
Dec 05 00:42:57 al kernel:  ffff880228940000 ffffffff818b4504 ffff880205d6b=
200 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88022893fca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bd956c0     0 23170  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8801d74fbc88 0000000000000082 ffff880232602=
580 ffff880205d6d780
Dec 05 00:42:57 al kernel:  ffff8801d74fc000 ffffffff818b4504 ffff880205d6d=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8801d74fbca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: sudo            D 0000000000000003     0 23270  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88023108bc88 0000000000000082 ffff880230ab8=
000 ffff8802141f6400
Dec 05 00:42:57 al kernel:  ffff88023108c000 ffffffff818b4504 ffff8802141f6=
400 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88023108bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff814ac6de>] ? netlink_insert+0x1ce/0x3=
50
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff8145e1a6>] ? sock_alloc_file+0xa6/0x1=
30
Dec 05 00:42:57 al kernel:  [<ffffffff811f0cb5>] ? fd_install+0x25/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81460aff>] ? SyS_socket+0x9f/0xf0
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bd156c0     0 23407  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8802143d7c88 0000000000000082 ffff880232601=
900 ffff88022daf4b00
Dec 05 00:42:57 al kernel:  ffff8802143d8000 ffffffff818b4504 ffff88022daf4=
b00 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8802143d7ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: sshd            D ffff88023bc956c0     0 23454  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800aca57c88 0000000000000086 ffff880232600=
c80 ffff8801d7e48000
Dec 05 00:42:57 al kernel:  ffff8800aca58000 ffffffff818b4504 ffff8801d7e48=
000 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800aca57ca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff814612c4>] ? SyS_getsockname+0xc4/0xe0
Dec 05 00:42:57 al kernel:  [<ffffffff81063136>] ? __do_page_fault+0x1a6/0x=
450
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bc156c0     0 23488  =
    1 0x00000004
Dec 05 00:42:57 al kernel:  ffff88021b45bc88 0000000000000082 ffffffff81812=
500 ffff8801d7e4d780
Dec 05 00:42:57 al kernel:  ffff88021b45c000 ffffffff818b4504 ffff8801d7e4d=
780 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff88021b45bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel: ip              D ffff88023bc956c0     0 23579  =
23578 0x00000004
Dec 05 00:42:57 al kernel:  ffff8800ad60bc88 0000000000000086 ffff880232600=
c80 ffff88009e1c8000
Dec 05 00:42:57 al kernel:  ffff8800ad60c000 ffffffff818b4504 ffff88009e1c8=
000 00000000ffffffff
Dec 05 00:42:57 al kernel:  ffffffff818b4508 ffff8800ad60bca0 ffffffff8157a=
09a ffffffff818b4500
Dec 05 00:42:57 al kernel: Call Trace:
Dec 05 00:42:57 al kernel:  [<ffffffff8157a09a>] schedule+0x3a/0x90
Dec 05 00:42:57 al kernel:  [<ffffffff8157a485>] schedule_preempt_disabled+=
0x15/0x20
Dec 05 00:42:57 al kernel:  [<ffffffff8157b8ce>] __mutex_lock_slowpath+0xce=
/0x140
Dec 05 00:42:57 al kernel:  [<ffffffff8157b957>] mutex_lock+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff8148e2f9>] rtnetlink_rcv+0x19/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff814adf0a>] netlink_unicast+0x11a/0x1a0
Dec 05 00:42:57 al kernel:  [<ffffffff814ae558>] netlink_sendmsg+0x4f8/0x610
Dec 05 00:42:57 al kernel:  [<ffffffff81460067>] sock_sendmsg+0x17/0x30
Dec 05 00:42:57 al kernel:  [<ffffffff81461500>] SyS_sendto+0x140/0x190
Dec 05 00:42:57 al kernel:  [<ffffffff811e3034>] ? putname+0x54/0x60
Dec 05 00:42:57 al kernel:  [<ffffffff811d3aab>] ? do_sys_open+0x1bb/0x230
Dec 05 00:42:57 al kernel:  [<ffffffff8157db2e>] entry_SYSCALL_64_fastpath+=
0x12/0x71
Dec 05 00:42:57 al kernel:=20
Dec 05 00:42:57 al kernel: Restarting tasks ... done.

--9jxsPFA5p3P2qPhR--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
