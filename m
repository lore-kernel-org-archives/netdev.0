From: Dave Jones <davej@redhat.com>
Subject: 3.1.0 rtl8169_open oops.
Date: Tue, 15 Nov 2011 17:37:02 -0500
Message-ID: <20111115223701.GA31118@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-team@fedoraproject.org, romieu@fr.zoreil.com,
	hayeswang@realtek.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757464Ab1KOWhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 17:37:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just had this reported by a user who hit this during installing Fedora 16.
(https://bugzilla.redhat.com/show_bug.cgi?id=753078)


BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffffa002ac0f>] rtl8169_open+0x34e/0x684 [r8169]
PGD 1f9f91067 PUD 210bad067 PMD 0 
Oops: 0000 [#1] SMP 
CPU 1 
Modules linked in: iscsi_ibft iscsi_boot_sysfs pcspkr edd iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi cramfs nouveau ttm drm_kms_helper drm i2c_algo_bit i2c_core r8169 mii video mxm_wmi wmi squashfs

Pid: 850, comm: NetworkManager Not tainted 3.1.0-7.fc16.x86_64 #1 Gigabyte Technology Co., Ltd. Z68A-D3H-B3/Z68A-D3H-B3
RIP: 0010:[<ffffffffa002ac0f>]  [<ffffffffa002ac0f>] rtl8169_open+0x34e/0x684 [r8169]
RSP: 0018:ffff8801fb7cb7a8  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffff88020fc6a000 RCX: 000000000000262b
RDX: 0000000000000af4 RSI: 0000000000000000 RDI: ffff88020fc6a000
RBP: ffff8801fb7cb818 R08: ffffea000820f1c0 R09: 0000000000543ad0
R10: 0000000000000000 R11: 0000000000012f80 R12: ffff88020fc6a740
R13: ffff880210a08280 R14: ffff88020676d9c0 R15: ffffffffa002c0e5
FS:  00007f629e776800(0000) GS:ffff88021f440000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 000000020fe0e000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process NetworkManager (pid: 850, threadinfo ffff8801fb7ca000, task ffff880207671730)
Stack:
 ffff8801fb7cb7e8 00000000dc61a000 ffff880211bef000 ffff88007f85e000
 ffffc90005cd4000 0000000000000ff0 ffff880211bef090 ffff880211bef090
 ffff8801fb7cb7f8 ffff88020fc6a000 ffffffffa002ca40 0000000000001000
Call Trace:
 [<ffffffff813d995c>] __dev_open+0x91/0xbf
 [<ffffffff813d9b90>] __dev_change_flags+0xab/0x12f
 [<ffffffff813d9c8d>] dev_change_flags+0x1e/0x54
 [<ffffffff813e42ac>] do_setlink+0x2b0/0x779
 [<ffffffff811ddb72>] ? avc_has_perm_flags+0x61/0x7a
 [<ffffffff813e49db>] rtnl_setlink+0xcd/0xed
 [<ffffffff811e3300>] ? selinux_netlink_recv.part.22+0x3a/0x9e
 [<ffffffff813e4d37>] rtnetlink_rcv_msg+0x23b/0x251
 [<ffffffff813e4afc>] ? __rtnl_unlock+0x17/0x17
 [<ffffffff813f8ca7>] netlink_rcv_skb+0x42/0x8d
 [<ffffffff813e3e88>] rtnetlink_rcv+0x26/0x2d
 [<ffffffff813f87b1>] netlink_unicast+0xec/0x156
 [<ffffffff813f8a9b>] netlink_sendmsg+0x280/0x2b8
 [<ffffffff813c62f7>] sock_sendmsg+0xe6/0x109
 [<ffffffff81450265>] ? scm_destroy+0x2b/0x4c
 [<ffffffff81044023>] ? should_resched+0xe/0x2d
 [<ffffffff814b4685>] ? _cond_resched+0xe/0x22
 [<ffffffff81044023>] ? should_resched+0xe/0x2d
 [<ffffffff813d0287>] ? copy_from_user+0x2f/0x31
 [<ffffffff813d0672>] ? verify_iovec+0x52/0xa4
 [<ffffffff813c65dc>] __sys_sendmsg+0x213/0x2ba
 [<ffffffff813c636f>] ? fput_light+0x12/0x14
 [<ffffffff813c81dd>] sys_sendmsg+0x42/0x60
 [<ffffffff814bc482>] system_call_fastpath+0x16/0x1b
Code: c6 d2 2b e1 85 c0 41 89 c6 0f 88 e4 01 00 00 4d 8b 75 00 48 8b bb 50 07 00 00 49 8b 16 49 8b 76 08 48 83 fa 03 0f 86 a8 00 00 00 
RIP  [<ffffffffa002ac0f>] rtl8169_open+0x34e/0x684 [r8169]
 RSP <ffff8801fb7cb7a8>
CR2: 0000000000000000
---[ end trace a9088da3782901d6 ]---


(gdb) list *(rtl8169_open)+0x34e
0x4c0f is in rtl8169_open (drivers/net/r8169.c:1881).
1876		bool rc = false;
1877	
1878		if (fw->size < FW_OPCODE_SIZE)
1879			goto out;
1880	
1881		if (!fw_info->magic) {
1882			size_t i, size, start;
1883			u8 checksum = 0;
1884	
1885			if (fw->size < sizeof(*fw_info))


	Dave
