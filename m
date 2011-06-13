From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 37202] New: Cannot change MTU on bridged
 interface
Date: Mon, 13 Jun 2011 16:37:35 -0700
Message-ID: <20110613163735.34c42044.akpm@linux-foundation.org>
References: <bug-37202-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	steve-alexander@roadrunner.com
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56029 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755212Ab1FMXhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 19:37:42 -0400
In-Reply-To: <bug-37202-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 11 Jun 2011 10:59:18 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=37202
> 
>            Summary: Cannot change MTU on bridged interface
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.0.0-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: steve-alexander@roadrunner.com
>         Regression: No
> 
> 
> Without bridge, setting mtu on eth0 works as expected.
> When eth0 is added to bridge 'br0' and this command is executed,
> 
> ip link set eth0 mtu 4000
> 
> results in:

erk.

Is this a new bug in 3.0-rc or have earlier kernels crashed in this manner?

Thanks.

> Modules linked in: fuse ip6table_filter ip6_tables ebtable_nat ebtables bridge
> stp llc sunrpc ipv6 kvm_intel kvm uinput snd_hda_codec_hdmi
> snd_hda_codec_realtek snd_hda_intel snd_hda_codec 
> snd_hwdep snd_seq i915 drm_kms_helper snd_seq_device drm iTCO_wdt i2c_algo_bit
> i2c_i801 ata_generic pata_acpi usblp i2c_core e1000e xhci_hcd video
> iTCO_vendor_support usb_storage snd_pcm se
> rio_raw joydev pata_jmicron pcspkr microcode snd_timer snd soundcore
> snd_page_alloc [last unloaded: scsi_wait_scan]
> 
> Pid: 4247, comm: ip Not tainted 3.0.0-rc2 #4 Gigabyte Technology Co., Ltd.
> H57M-USB3/H57M-USB3
> RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
> RSP: 0018:ffff8801e419d680  EFLAGS: 00010202
> RAX: 0000000000000640 RBX: 0000000000000640 RCX: ffff880212874788
> RDX: ffffffffa0347e00 RSI: ffffffffa0345c21 RDI: ffff880212874fb0
> RBP: ffff8801e419d6a8 R08: 0000000000000000 R09: ffffffff81666030
> R10: ffffffff81a7a3a0 R11: 0000000000000001 R12: ffff880212874000
> R13: ffff880212874780 R14: 00000000ffffffea R15: ffffffffa00e4030
> FS:  00007effa3ca6720(0000) GS:ffff88021fcc0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 00000001e401b000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process ip (pid: 4247, threadinfo ffff8801e419c000, task ffff8801f5f14560)
> Stack:
>  ffffffffa033b1a6 ffff880212874000 00000000ffffffed ffff8801f50af400
>  ffff880211dc4000 ffff8801e419d6c8 ffffffff813ba810 0000000000000007
>  ffff880212874780 ffff8801e419d6f8 ffffffffa033e2b4 ffff880211dc4000
> 
> Call Trace:
>  [<ffffffffa033b1a6>] ? br_change_mtu+0x61/0x81 [bridge]
>  [<ffffffff813ba810>] dev_set_mtu+0x45/0x75
>  [<ffffffffa033e2b4>] br_device_event+0x7c/0x16c [bridge]
>  [<ffffffff8146f921>] notifier_call_chain+0x37/0x63
>  [<ffffffff8106d934>] raw_notifier_call_chain+0x14/0x16
>  [<ffffffff813ba107>] call_netdevice_notifiers+0x4a/0x4f
>  [<ffffffff813ba838>] dev_set_mtu+0x6d/0x75
>  [<ffffffff813c8da2>] do_setlink+0x1ee/0x739
>  [<ffffffff810e8052>] ? set_pte_at+0xe/0x12
>  [<ffffffff8122e1de>] ? nla_parse+0x4f/0xc3
>  [<ffffffff813c9f45>] rtnl_newlink+0x252/0x48d
>  [<ffffffff813c9db7>] ? rtnl_newlink+0xc4/0x48d
>  [<ffffffff8103d040>] ? need_resched+0x23/0x2d
>  [<ffffffff813af3e3>] ? sock_rmalloc+0x33/0x95
>  [<ffffffff813c9afe>] rtnetlink_rcv_msg+0x1eb/0x201
>  [<ffffffff8103d040>] ? need_resched+0x23/0x2d
>  [<ffffffff813c9913>] ? __rtnl_unlock+0x17/0x17
>  [<ffffffff813dd9a8>] netlink_rcv_skb+0x45/0x90
>  [<ffffffff813c94c4>] rtnetlink_rcv+0x26/0x2d
>  [<ffffffff813dd4b3>] netlink_unicast+0xf1/0x15a
>  [<ffffffff813dd7a1>] netlink_sendmsg+0x285/0x2a3
>  [<ffffffff8110c558>] ? fatal_signal_pending+0x12/0x29
>  [<ffffffff813a9e7d>] __sock_sendmsg+0x6a/0x76
>  [<ffffffff813aa764>] sock_sendmsg+0xa8/0xc1
>  [<ffffffff810cf7b0>] ? filemap_fault+0x20b/0x36c
>  [<ffffffff810cde20>] ? unlock_page+0x2a/0x2f
>  [<ffffffff810e8a1a>] ? __do_fault+0x34d/0x384
>  [<ffffffff8103d040>] ? need_resched+0x23/0x2d
>  [<ffffffff8103d058>] ? should_resched+0xe/0x2e
>  [<ffffffff8103d040>] ? need_resched+0x23/0x2d
>  [<ffffffff8103d058>] ? should_resched+0xe/0x2e
>  [<ffffffff813b406e>] ? copy_from_user+0x2f/0x31
>  [<ffffffff813b445e>] ? verify_iovec+0x54/0xa6
>  [<ffffffff813aaa1a>] __sys_sendmsg+0x1ee/0x272
>  [<ffffffff810eb570>] ? handle_mm_fault+0x149/0x15e
>  [<ffffffff8146c5b6>] ? _raw_spin_lock+0xe/0x10
>  [<ffffffff8146f8ab>] ? do_page_fault+0x321/0x360
>  [<ffffffff810efda4>] ? do_brk+0x242/0x296
>  [<ffffffff813ac02f>] sys_sendmsg+0x42/0x60
>  [<ffffffff81472d42>] system_call_fastpath+0x16/0x1b
> Code:  Bad RIP value.
> RIP  [<          (null)>]           (null)
>  RSP <ffff8801e419d680>
> CR2: 0000000000000000
> ---[ end trace 29a99239194ab188 ]---
> 
> 
> Bridge creation is managed by Fedora14 standard configs.
> eth0 is the only interface added to the bridge.
> 
> eth0 is 
> 03:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit Network
> Connection [8086:10d3]
>     Subsystem: Intel Corporation Gigabit CT Desktop Adapter [8086:a01f]
>     Kernel driver in use: e1000e
>     Kernel modules: e1000e
> 

