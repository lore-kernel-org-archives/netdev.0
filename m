From: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from invalid
 context at mm/slub.c:1719
Date: Fri, 02 Oct 2009 08:28:26 +0200
Message-ID: <4AC59D8A.6000102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Marcel,

with current net-2.6 tree ...

While starting my PPP Bluetooth dialup networking, i got this:

[  722.461549] PPP generic driver version 2.4.2
[  722.477519] BUG: sleeping function called from invalid context at
mm/slub.c:1719
[  722.477530] in_atomic(): 1, irqs_disabled(): 0, pid: 4677, name: pppd
[  722.477537] 3 locks held by pppd/4677:
[  722.477542]  #0:  (rfcomm_mutex){+.+.+.}, at: [<fa5df2a1>]
rfcomm_dlc_open+0x28/0x2d6 [rfcomm]
[  722.477568]  #1:  (sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP){+.+.+.}, at:
[<fa5414f8>] l2cap_sock_connect+0x62/0x2c6 [l2cap]
[  722.477589]  #2:  (&hdev->lock){+...+.}, at: [<fa5415b4>]
l2cap_sock_connect+0x11e/0x2c6 [l2cap]
[  722.477613] Pid: 4677, comm: pppd Not tainted 2.6.31-08939-gdb8abec-dirty #21
[  722.477619] Call Trace:
[  722.477633]  [<c1042a2b>] ? __debug_show_held_locks+0x1e/0x20
[  722.477644]  [<c10212a1>] __might_sleep+0xc9/0xce
[  722.477655]  [<c1078b62>] __kmalloc+0x6d/0xfb
[  722.477666]  [<c119e739>] ? kzalloc+0xb/0xd
[  722.477674]  [<c119e739>] kzalloc+0xb/0xd
[  722.477683]  [<c119ef1a>] device_private_init+0x15/0x3d
[  722.477693]  [<c11a0e1b>] dev_set_drvdata+0x18/0x26
[  722.477718]  [<f8b7ca1b>] hci_conn_init_sysfs+0x3d/0xc7 [bluetooth]
[  722.477737]  [<f8b791b3>] hci_conn_add+0x1c0/0x1d5 [bluetooth]
[  722.477756]  [<f8b79360>] hci_connect+0x71/0x17d [bluetooth]
[  722.477769]  [<fa54162c>] l2cap_sock_connect+0x196/0x2c6 [l2cap]
[  722.477782]  [<c1246e3d>] kernel_connect+0xd/0x12
[  722.477795]  [<fa5df3c3>] rfcomm_dlc_open+0x14a/0x2d6 [rfcomm]
[  722.477810]  [<fa5e10fa>] ? rfcomm_tty_open+0x73/0x227 [rfcomm]
[  722.477825]  [<fa5e1130>] rfcomm_tty_open+0xa9/0x227 [rfcomm]
[  722.477836]  [<c1022e3f>] ? default_wake_function+0x0/0xd
[  722.477847]  [<c1180c79>] tty_open+0x29e/0x399
[  722.477858]  [<c107e9bd>] chrdev_open+0x13f/0x156
[  722.477868]  [<c107b0d3>] __dentry_open+0x11b/0x20f
[  722.477878]  [<c107b261>] nameidata_to_filp+0x2c/0x43
[  722.477888]  [<c107e87e>] ? chrdev_open+0x0/0x156
[  722.477898]  [<c1084e9e>] do_filp_open+0x3c6/0x70a
[  722.477910]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
[  722.477920]  [<c108d3e4>] ? alloc_fd+0xc8/0xd2
[  722.477930]  [<c107aebc>] do_sys_open+0x4a/0xe7
[  722.477940]  [<c1002acc>] ? restore_all_notrace+0x0/0x18
[  722.477950]  [<c107af9b>] sys_open+0x1e/0x26
[  722.477959]  [<c1002a18>] sysenter_do_call+0x12/0x36
[  729.658613] PPP BSD Compression module registered
[  729.684789] PPP Deflate Compression module registered

Any idea?

Regards,
Oliver
