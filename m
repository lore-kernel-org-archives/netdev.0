From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Fri, 6 Jul 2012 06:20:58 +0300
Message-ID: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:46776 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751703Ab2GFDVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 23:21:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Shlomo saw too the ipv6 dst crash that was reported over
the list and also this warning when he rebased to net-next yesterday

Or.


[  285.551769] ------------[ cut here ]------------
[  285.552693] WARNING: at kernel/softirq.c:159 local_bh_enable+0x7a/0xa0()
[  285.552693] Hardware name: X7DWU
[  285.552693] Modules linked in: ib_ipoib ib_cm ib_sa mlx4_ib mlx4_en
mlx4_core ib_mad ib_core netconsole nfs lockd fscache auth_rpcgss nfs_acl
bnx2fc cnic 8021q uio garp fcoe libfcoe stp libfc llc scsi_transport_fc
scsi_tgt sunrpc binfmt_misc uinput joydev coretemp kvm_intel kvm microcode
pcspkr serio_raw i2c_i801 lpc_ich mfd_core i5400_edac edac_core i5k_amb
igb ptp pps_core ioatdma ixgbe dca mdio shpchp usb_storage floppy radeon
ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded:
scsi_wait_scan]

[  285.552693] Pid: 1662, comm: avahi-daemon Not tainted 3.5.0-rc5+ #2
[  285.552693] Call Trace:
[  285.552693]  [<ffffffff81058ebf>] warn_slowpath_common+0x7f/0xc0
[  285.552693]  [<ffffffff81058f1a>] warn_slowpath_null+0x1a/0x20
[  285.552693]  [<ffffffff810618ba>] local_bh_enable+0x7a/0xa0
[  285.552693]  [<ffffffff815294e0>] ipv4_neigh_lookup+0xc0/0x130
[  285.552693]  [<ffffffffa04f0966>] ipoib_mcast_send+0x1b6/0x480 [ib_ipoib]
[  285.552693]  [<ffffffff81093716>] ? update_sd_lb_stats+0x146/0x690
[  285.552693]  [<ffffffff814eb35b>] ? __alloc_skb+0x4b/0x170
[  285.552693]  [<ffffffffa04ec15d>] ipoib_path_lookup+0x11d/0x300 [ib_ipoib]
[  285.552693]  [<ffffffff814eb35b>] ? __alloc_skb+0x4b/0x170
[  285.552693]  [<ffffffff814e7718>] ? sock_alloc_send_pskb+0x1d8/0x380
[  285.552693]  [<ffffffffa04ec97d>] ipoib_start_xmit+0x1ad/0x430 [ib_ipoib]
[  285.552693]  [<ffffffff814fa64a>] dev_hard_start_xmit+0x24a/0x670
[  285.552693]  [<ffffffff8151790a>] sch_direct_xmit+0xfa/0x1d0
[  285.552693]  [<ffffffff814fabff>] dev_queue_xmit+0x18f/0x5e0
[  285.552693]  [<ffffffff81503667>] neigh_connected_output+0xc7/0x110
[  285.552693]  [<ffffffff81535c0d>] ip_finish_output+0x2ed/0x410
[  285.552693]  [<ffffffff81535ee9>] ip_mc_output+0x119/0x250
[  285.552693]  [<ffffffff81534fe9>] ip_local_out+0x29/0x30
[  285.552693]  [<ffffffff8153500b>] ip_send_skb+0x1b/0x50
[  285.552693]  [<ffffffff815598ad>] udp_send_skb+0x10d/0x3a0
[  285.552693]  [<ffffffff81534190>] ? ip_append_page+0x500/0x500
[  285.552693]  [<ffffffff8155ab9b>] udp_sendmsg+0x33b/0x970
[  285.552693]  [<ffffffff81080650>] ? update_rmtp+0x80/0x80
[  285.552693]  [<ffffffff81198011>] ? do_sys_poll+0x351/0x510
[  285.552693]  [<ffffffff81563a78>] inet_sendmsg+0x48/0xb0
[  285.552693]  [<ffffffff814e3398>] sock_sendmsg+0xf8/0x130
[  285.552693]  [<ffffffff81197330>] ? __pollwait+0xf0/0xf0
[  285.552693]  [<ffffffff81060707>] ? current_fs_time+0x27/0x30
[  285.552693]  [<ffffffff8119d3e1>] ? update_time+0x81/0xc0
[  285.552693]  [<ffffffff81197330>] ? __pollwait+0xf0/0xf0
[  285.552693]  [<ffffffff8119d469>] ? file_update_time+0x49/0xe0
[  285.552693]  [<ffffffff814e1e6e>] ? move_addr_to_kernel+0x4e/0x90
[  285.552693]  [<ffffffff814e1690>] ? copy_from_user+0x30/0x40
[  285.552693]  [<ffffffff814e4acd>] __sys_sendmsg+0x3fd/0x420
[  285.552693]  [<ffffffff81184aa2>] ? do_sync_write+0xe2/0x120
[  285.552693]  [<ffffffff811c1b05>] ? fsnotify+0x1d5/0x2f0
[  285.552693]  [<ffffffff814e4cf9>] sys_sendmsg+0x49/0x90
[  285.552693]  [<ffffffff81607da9>] system_call_fastpath+0x16/0x1b
[  285.552693] ---[ end trace cabd6aea7003ad6f ]---
