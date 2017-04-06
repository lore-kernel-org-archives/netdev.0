From: "Peter V. Saveliev" <peter@svinota.eu>
Subject: [BUG] kernel oops during bridge creation
Date: Thu, 6 Apr 2017 20:19:35 +0200
Message-ID: <4d4b58e0-06e5-de5a-3305-abc739cf2ba2@svinota.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.peet.spb.ru ([164.138.27.30]:59733 "EHLO
        saaristo.svinota.eu" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1753388AbdDFS1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 14:27:18 -0400
Received: from svinosund.norden (localhost [127.0.0.1])
        by saaristo.svinota.eu (Postfix) with ESMTPSA id 2B88C1824E
        for <netdev@vger.kernel.org>; Thu,  6 Apr 2017 20:19:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Operation:

# ip link add name test type bridge vlan_default_pvid 1

Result:

Kernel oops. Minimal required netlink packet structure:

ifinfmsg:
	- IFLA_IFNAME: "test"
	- IFLA_LINKINFO:
		= IFLA_INFO_KIND: "bridge"
		= IFLA_INFO_DATA:
			- IFLA_BR_VLAN_DEFAULT_PVID: 1

Reproducible: always

Versions affected: all the latest kernels, including net-next

Possibly related to 
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b6677449dff674cf5b81429b11d5c7f358852ef9

Trace:

[13634.939408] BUG: unable to handle kernel NULL pointer dereference at 
0000000000000190
[13634.939436] IP: __vlan_add+0x73/0x5f0
[13634.939445] PGD 3dfe0067
[13634.939445] PUD 35807067
[13634.939451] PMD 0

[13634.939467] Oops: 0002 [#1] SMP
[13634.939474] Modules linked in: crct10dif_pclmul crc32_pclmul 
ghash_clmulni_intel pcbc qxl ttm drm_kms_helper drm aesni_intel 
aes_x86_64 crypto_simd glue_helper cryptd virtio_balloon evdev 
input_leds pcspkr led_class serio_raw virtio_console i2c_piix4 
acpi_cpufreq tpm_tis tpm_tis_core tpm button ext4 crc16 jbd2 mbcache 
virtio_net virtio_blk crc32c_intel psmouse 8139cp mii virtio_pci 
virtio_ring virtio
[13634.939561] CPU: 0 PID: 1535 Comm: ip Not tainted 4.11.0-rc3+ #6
[13634.939574] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3-1.fc25 04/01/2014
[13634.939593] task: ffff9b4838f5a000 task.stack: ffffc1b74046c000
[13634.939607] RIP: 0010:__vlan_add+0x73/0x5f0
[13634.939617] RSP: 0018:ffffc1b74046f668 EFLAGS: 00010246
[13634.939629] RAX: 0000000000000000 RBX: ffff9b483522d680 RCX: 
0000000000000000
[13634.939644] RDX: ffffffffbe8f2978 RSI: 0000000000000200 RDI: 
ffffffffbe2c120f
[13634.939659] RBP: 0000000000000000 R08: 0000000000000000 R09: 
0000000000000000
[13634.939674] R10: 0000000000000000 R11: 000000000000c609 R12: 
0000000000000000
[13634.939689] R13: ffff9b48350ae8c0 R14: ffff9b48350ae000 R15: 
0000000000000000
[13634.939705] FS:  00007fe5e4f13700(0000) GS:ffff9b483fc00000(0000) 
knlGS:0000000000000000
[13634.939722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[13634.939734] CR2: 0000000000000190 CR3: 0000000035805000 CR4: 
00000000000406f0
[13634.939752] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[13634.939767] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[13634.939783] Call Trace:
[13634.939791]  ? pcpu_next_unpop+0x3b/0x50
[13634.939801]  ? pcpu_alloc+0x3d2/0x680
[13634.939810]  ? br_vlan_add+0x135/0x1b0
[13634.939820]  ? __br_vlan_set_default_pvid.part.28+0x204/0x2b0
[13634.939834]  ? br_changelink+0x120/0x4e0
[13634.939844]  ? br_dev_newlink+0x50/0x70
[13634.939854]  ? rtnl_newlink+0x5f5/0x8a0
[13634.939864]  ? rtnl_newlink+0x176/0x8a0
[13634.939874]  ? mem_cgroup_commit_charge+0x7c/0x4e0
[13634.939886]  ? rtnetlink_rcv_msg+0xe1/0x220
[13634.939896]  ? lookup_fast+0x52/0x370
[13634.939905]  ? rtnl_newlink+0x8a0/0x8a0
[13634.939915]  ? netlink_rcv_skb+0xa1/0xc0
[13634.939925]  ? rtnetlink_rcv+0x24/0x30
[13634.939934]  ? netlink_unicast+0x177/0x220
[13634.939944]  ? netlink_sendmsg+0x2fe/0x3b0
[13634.939954]  ? _copy_from_user+0x39/0x40
[13634.939964]  ? sock_sendmsg+0x30/0x40
[13634.940159]  ? ___sys_sendmsg+0x29d/0x2b0
[13634.940326]  ? __alloc_pages_nodemask+0xdf/0x230
[13634.940478]  ? mem_cgroup_commit_charge+0x7c/0x4e0
[13634.940592]  ? mem_cgroup_try_charge+0x76/0x1a0
[13634.940701]  ? __handle_mm_fault+0xdb9/0x10b0
[13634.940809]  ? __sys_sendmsg+0x51/0x90
[13634.940917]  ? entry_SYSCALL_64_fastpath+0x1e/0xad
[13634.941027] Code: 75 18 49 8b 6d 30 a8 20 74 29 0f b7 4b 10 49 8b 96 
28 03 00 00 4c 89 e6 4c 89 ef e8 88 eb fe ff 85 c0 41 89 c7 0f 85 58 05 
00 00 <66> 83 85 90 01 00 00 01 48 8b 45 30 48 89 c2 48 f7 da 48 83 7d
[13634.941301] RIP: __vlan_add+0x73/0x5f0 RSP: ffffc1b74046f668
[13634.941423] CR2: 0000000000000190
[13634.943641] ---[ end trace bb793e957e3e263c ]---

…

Thanks.
