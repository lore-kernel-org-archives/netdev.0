From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: openconnect triggers soft lockup in __skb_get_rxhash
Date: Mon, 17 Dec 2012 02:56:17 +0200
Message-ID: <20121217005616.GA23029@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shutemov.name ([204.155.152.216]:37647 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab2LQBED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 20:04:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In few minutes after starting openconnect it starts consume 100% CPU and I
can see soft lockup report in dmesg:

[  231.684591] BUG: soft lockup - CPU#3 stuck for 22s! [openconnect:3537]
[  231.684595] Modules linked in: rfcomm bnep iwldvm btusb iwlwifi bluetooth acpi_cpufreq container mperf thermal battery ac processor
[  231.684607] CPU 3 
[  231.684610] Pid: 3537, comm: openconnect Not tainted 3.7.0-08585-g2a74dbb #165 Hewlett-Packard HP EliteBook 8440p/172A
[  231.684612] RIP: 0010:[<ffffffff815f3f62>]  [<ffffffff815f3f62>] skb_flow_dissect+0x52/0x3b0
[  231.684621] RSP: 0018:ffff88012ebbdc48  EFLAGS: 00000246
[  231.684622] RAX: 0000000000000004 RBX: ffffffff8173b360 RCX: ff040404ff040404
[  231.684623] RDX: 0000000000000000 RSI: ffff88012ebbdcc8 RDI: ffff880122770e00
[  231.684624] RBP: ffff88012ebbdcb8 R08: 00000000000004f2 R09: ffff88012faa6000
[  231.684626] R10: ffff880122770e00 R11: 0000000000000000 R12: ffffffff8173b476
[  231.684627] R13: 0000000010000002 R14: ffff88012ebbc000 R15: 0000000000000004
[  231.684628] FS:  00007f31249d9740(0000) GS:ffff880132e00000(0000) knlGS:0000000000000000
[  231.684630] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  231.684631] CR2: 00007fed86cca000 CR3: 0000000122489000 CR4: 00000000000007e0
[  231.684632] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  231.684633] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  231.684635] Process openconnect (pid: 3537, threadinfo ffff88012ebbc000, task ffff8801305be4a0)
[  231.684636] Stack:
[  231.684637]  ffff88012ebbdce8 ffffffff815f0072 ffff8801305be4a0 00000000000004f2
[  231.684640]  0000000000000000 00000000000004f2 00000000000004f2 0000000000000000
[  231.684643]  ffff88012ebbdce8 00000000748aa9b5 ffff880122770e00 ffff88012ebbddf0
[  231.684646] Call Trace:
[  231.684651]  [<ffffffff815f0072>] ? memcpy_fromiovecend+0x72/0xc0
[  231.684654]  [<ffffffff815f71fa>] __skb_get_rxhash+0x1a/0xd0
[  231.684659]  [<ffffffff814a04a8>] tun_get_user+0x5b8/0x7b0
[  231.684662]  [<ffffffff8149ea79>] ? __tun_get+0x59/0x80
[  231.684664]  [<ffffffff814a07b1>] tun_chr_aio_write+0x81/0xb0
[  231.684670]  [<ffffffff810e342e>] ? put_lock_stats.isra.15+0xe/0x40
[  231.684675]  [<ffffffff811ac857>] do_sync_write+0xa7/0xe0
[  231.684678]  [<ffffffff811acf7b>] vfs_write+0xab/0x190
[  231.684681]  [<ffffffff811ad2f5>] sys_write+0x55/0xb0
[  231.684684]  [<ffffffff81742906>] system_call_fastpath+0x1a/0x1f
[  231.684685] Code: 31 c0 44 8b a7 a0 00 00 00 44 0f b7 6f 76 4c 03 a7 b0 00 00 00 44 2b a7 b8 00 00 00 48 c7 06 00 00 00 00 48 c7 46 08 00 00 00 00 <66> 41 81 fd 81 00 0f 84 72 01 00 00 77 70 66 41 83 fd 08 74 29 

-- 
 Kirill A. Shutemov
