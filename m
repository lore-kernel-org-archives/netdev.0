From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15097] New: NULL pointer dereference somewhere
 in the forcedeth driver
Date: Tue, 26 Jan 2010 14:23:47 -0800
Message-ID: <20100126142347.4bb57493.akpm@linux-foundation.org>
References: <bug-15097-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, redchrom@gmail.com
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54300 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752731Ab0AZWYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 17:24:22 -0500
In-Reply-To: <bug-15097-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 20 Jan 2010 23:26:52 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15097
> 
>            Summary: NULL pointer dereference somewhere in the forcedeth
>                     driver
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.31.9-174.fc12.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: redchrom@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=24663)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24663)
> cur from /var/log/messages
> 
> First cycle of suspend/resume works ok, but on the second kernel hangs (log
> attached). The problem appeared somewhere during Fedora 12 kernel updates.
> 
> ...
>
> Jan 21 01:49:40 localhost kernel: BUG: unable to handle kernel NULL pointer dereference at 00000000000000da
> Jan 21 01:49:40 localhost kernel: IP: [<ffffffff81383400>] dst_release+0x11/0x30
> Jan 21 01:49:40 localhost kernel: PGD 7090d067 PUD 70876067 PMD 0 
> Jan 21 01:49:40 localhost kernel: Oops: 0002 [#1] SMP 
> Jan 21 01:49:40 localhost kernel: last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> Jan 21 01:49:40 localhost kernel: CPU 0 
> Jan 21 01:49:40 localhost kernel: Modules linked in: fuse ipt_MASQUERADE iptable_nat nf_nat rfcomm sco bridge stp llc bnep l2cap sunrpc ipv6 cpufreq_ondemand powernow_k8 freq_table dm_multipath kvm_amd kvm uinput snd_hda_codec_si3054 nvidia(P) snd_hda_codec_realtek arc4 ecb snd_hda_intel ath5k snd_hda_codec mac80211 uvcvideo sdhci_pci firewire_ohci btusb sdhci snd_hwdep firewire_core snd_seq bluetooth amd64_edac_mod snd_seq_device ath videodev mmc_core snd_pcm edac_core v4l1_compat crc_itu_t cfg80211 asus_laptop rfkill snd_timer i2c_nforce2 v4l2_compat_ioctl32 k8temp forcedeth i2c_core ricoh_mmc snd serio_raw joydev soundcore snd_page_alloc ata_generic pata_acpi pata_amd video output [last unloaded: scsi_wait_scan]
> Jan 21 01:49:40 localhost kernel: Pid: 1209, comm: NetworkManager Tainted: P           2.6.31.9-174.fc12.x86_64 #1 A8N                 
> Jan 21 01:49:40 localhost kernel: RIP: 0010:[<ffffffff81383400>]  [<ffffffff81383400>] dst_release+0x11/0x30
> Jan 21 01:49:40 localhost kernel: RSP: 0018:ffff8800708c57d8  EFLAGS: 00010286
> Jan 21 01:49:40 localhost kernel: RAX: 00000000ffffffff RBX: ffff880077d44000 RCX: 0000000000000002
> Jan 21 01:49:40 localhost kernel: RDX: 0000000000000660 RSI: 000000006f448020 RDI: 000000000000001a
> Jan 21 01:49:40 localhost kernel: RBP: ffff8800708c57d8 R08: 0000000000000000 R09: 0000000000000004
> Jan 21 01:49:40 localhost kernel: R10: 0000000000000000 R11: ffff8800708c57a8 R12: 0000000000000053
> Jan 21 01:49:40 localhost kernel: R13: 0000000000000cf8 R14: 0000000000000000 R15: 0000000000000001
> Jan 21 01:49:40 localhost kernel: FS:  00007f59c44fb800(0000) GS:ffff8800019c1000(0000) knlGS:0000000000000000
> Jan 21 01:49:40 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Jan 21 01:49:40 localhost kernel: CR2: 00000000000000da CR3: 00000000708fa000 CR4: 00000000000006f0
> Jan 21 01:49:40 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jan 21 01:49:40 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jan 21 01:49:40 localhost kernel: Process NetworkManager (pid: 1209, threadinfo ffff8800708c4000, task ffff88007083c680)
> Jan 21 01:49:40 localhost kernel: Stack:
> Jan 21 01:49:40 localhost kernel: ffff8800708c57f8 ffffffff813767ac 0000000000000052 ffff880077d44000
> Jan 21 01:49:40 localhost kernel: <0> ffff8800708c5818 ffffffff81376563 0000000000000000 ffff880076a845c0
> Jan 21 01:49:40 localhost kernel: <0> ffff8800708c5828 ffffffff813765fb ffff8800708c5858 ffffffffa007221e
> Jan 21 01:49:40 localhost kernel: Call Trace:
> Jan 21 01:49:40 localhost kernel: [<ffffffff813767ac>] skb_release_head_state+0x1f/0xd7
> Jan 21 01:49:40 localhost kernel: [<ffffffff81376563>] __kfree_skb+0x16/0x81
> Jan 21 01:49:40 localhost kernel: [<ffffffff813765fb>] consume_skb+0x2d/0x2f
> Jan 21 01:49:40 localhost kernel: [<ffffffffa007221e>] nv_drain_rxtx+0xaf/0x11c [forcedeth]
> Jan 21 01:49:40 localhost kernel: [<ffffffffa007237a>] nv_close+0xef/0x199 [forcedeth]
> Jan 21 01:49:40 localhost kernel: [<ffffffff813801fc>] dev_close+0x84/0xa4
> Jan 21 01:49:40 localhost kernel: [<ffffffff8137fb9d>] dev_change_flags+0xad/0x16e
> Jan 21 01:49:40 localhost kernel: [<ffffffff81389009>] do_setlink+0x28e/0x35f
> Jan 21 01:49:40 localhost kernel: [<ffffffff813891ed>] rtnl_setlink+0x113/0x126
> Jan 21 01:49:40 localhost kernel: [<ffffffff81388a32>] rtnetlink_rcv_msg+0x1c6/0x1e3
> Jan 21 01:49:40 localhost kernel: [<ffffffff81399cf9>] ? netlink_sendmsg+0x185/0x28e
> Jan 21 01:49:40 localhost kernel: [<ffffffff8138886c>] ? rtnetlink_rcv_msg+0x0/0x1e3
> Jan 21 01:49:40 localhost kernel: [<ffffffff81399fc2>] netlink_rcv_skb+0x43/0x95
> Jan 21 01:49:40 localhost kernel: [<ffffffff81388865>] rtnetlink_rcv+0x26/0x2d
> Jan 21 01:49:40 localhost kernel: [<ffffffff81399b0b>] netlink_unicast+0x125/0x18e
> Jan 21 01:49:40 localhost kernel: [<ffffffff81399df3>] netlink_sendmsg+0x27f/0x28e
> Jan 21 01:49:40 localhost kernel: [<ffffffff81372735>] ? sock_def_readable+0x59/0x64
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136eddb>] __sock_sendmsg+0x61/0x6c
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136f552>] sock_sendmsg+0xcc/0xe5
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136f41c>] ? sock_recvmsg+0xcf/0xe8
> Jan 21 01:49:40 localhost kernel: [<ffffffff81067b37>] ? autoremove_wake_function+0x0/0x39
> Jan 21 01:49:40 localhost kernel: [<ffffffff81067b37>] ? autoremove_wake_function+0x0/0x39
> Jan 21 01:49:40 localhost kernel: [<ffffffff81370109>] ? move_addr_to_kernel+0x48/0x4d
> Jan 21 01:49:40 localhost kernel: [<ffffffff813789ab>] ? verify_iovec+0x51/0x8e
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136f78c>] sys_sendmsg+0x221/0x2a5
> Jan 21 01:49:40 localhost kernel: [<ffffffff810f1b05>] ? virt_to_head_page+0xe/0x2f
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136ee97>] ? sockfd_lookup_light+0x20/0x58
> Jan 21 01:49:40 localhost kernel: [<ffffffff8136ee75>] ? fput_light+0x12/0x14
> Jan 21 01:49:40 localhost kernel: [<ffffffff81370233>] ? sys_sendto+0x125/0x152
> Jan 21 01:49:40 localhost kernel: [<ffffffff810fdb75>] ? __fput+0x1cb/0x1da
> Jan 21 01:49:40 localhost kernel: [<ffffffff8110447d>] ? path_put+0x22/0x27
> Jan 21 01:49:40 localhost kernel: [<ffffffff81095ed8>] ? audit_syscall_entry+0x11e/0x14a
> Jan 21 01:49:40 localhost kernel: [<ffffffff81011cf2>] system_call_fastpath+0x16/0x1b
> Jan 21 01:49:40 localhost kernel: Code: db 75 e0 48 c7 c7 00 c9 6c 81 e8 0d 90 09 00 5b 41 5c 41 5d 31 c0 41 5e c9 c3 55 48 89 e5 0f 1f 44 00 00 48 85 ff 74 20 83 c8 ff <f0> 0f c1 87 c0 00 00 00 ff c8 79 11 be 0e 01 00 00 48 c7 c7 5a 
> Jan 21 01:49:40 localhost kernel: RIP  [<ffffffff81383400>] dst_release+0x11/0x30
> Jan 21 01:49:40 localhost kernel: RSP <ffff8800708c57d8>
> Jan 21 01:49:40 localhost kernel: CR2: 00000000000000da
> Jan 21 01:49:40 localhost kernel: ---[ end trace aa7e36c409fa90fa ]---
> J
> 

