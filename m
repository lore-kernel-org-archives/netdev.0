From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Tue, 10 Feb 2009 11:33:45 -0700
Message-ID: <1234290825.25178.100.camel@bling>
References: <20090204104825.GA21257@gondor.apana.org.au>
	 <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:45005 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbZBJSgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 13:36:07 -0500
In-Reply-To: <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 21:49 +1100, Herbert Xu wrote:
> tun: Limit amount of queued packets per device

Hi Herbert,

I'm getting a variety of Oopses, null pointer derefs, etc... from this
patch when trying to run a qemu guest on net-next-2.6 using a standard
tap/bridge config.  I've included a sample below.  Thanks,

Alex


[  173.231609] BUG: unable to handle kernel paging request at ffffffffffff8871
[  173.233252] IP: [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
[  173.233252] PGD 203067 PUD 204067 PMD 0 
[  173.233252] Oops: 0000 [#1] SMP 
[  173.233252] last sysfs file: /sys/kernel/uevent_seqnum
[  173.233252] CPU 5 
[  173.233252] Modules linked in: tun nfs lockd nfs_acl auth_rpcgss sunrpc iptable_filter ip_tables ebtable_broute bridge stp ebtable_nat ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf hpilo ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support hpwdt i5000_edac serio_raw edac_core psmouse pcspkr shpchp button container i5k_amb pci_hotplug joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod ehci_hcd uhci_hcd lpfc scsi_transport_fc usbcore cciss scsi_tgt scsi_mod bnx2 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
[  173.233252] Pid: 6770, comm: qemu-system-x86 Not tainted 2.6.29-rc3 #4
[  173.233252] RIP: 0010:[<ffffffff8044875e>]  [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
[  173.233252] RSP: 0018:ffff880827cbfc68  EFLAGS: 00010292
[  173.233252] RAX: 0000000000000000 RBX: ffffffffffff8809 RCX: 0000000000000148
[  173.233252] RDX: ffff880827cbfe78 RSI: 0000000000000000 RDI: ffffffffffff8809
[  173.233252] RBP: ffffffffffff8809 R08: ffff880827cbfcf4 R09: 0000000000000000
[  173.233252] R10: 0000000000000000 R11: ffffffff80350440 R12: 0000000000000148
[  173.233252] R13: ffff88082b414840 R14: 0000000000000000 R15: 0000000000000148
[  173.233252] FS:  00007f184f8756e0(0000) GS:ffff88082bfe1100(0000) knlGS:0000000000000000
[  173.233252] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  173.233252] CR2: ffffffffffff8871 CR3: 000000081d963000 CR4: 00000000000006e0
[  173.233252] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  173.233252] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  173.233252] Process qemu-system-x86 (pid: 6770, threadinfo ffff880827cbe000, task ffff88082bb7cbc0)
[  173.233252] Stack:
[  173.233252]  000000000000001e 000000000000001e ffff880827cbfe78 ffffffffffff8809
[  173.233252]  000000004991c50c ffffffffffff8809 ffffffffffff8809 0000000000000148
[  173.233252]  ffff88082b414840 0000000000000156 0000000000000148 ffffffffa047f5ac
[  173.233252] Call Trace:
[  173.233252]  [<ffffffffa047f5ac>] ? tun_chr_aio_write+0x19c/0x440 [tun]
[  173.233252]  [<ffffffff802b68ad>] ? zone_statistics+0x7d/0x80
[  173.233252]  [<ffffffffa047f410>] ? tun_chr_aio_write+0x0/0x440 [tun]
[  173.233252]  [<ffffffff802df90b>] ? do_sync_readv_writev+0xcb/0x110
[  173.233252]  [<ffffffff80261f90>] ? autoremove_wake_function+0x0/0x30
[  173.233252]  [<ffffffff802dcf25>] ? mem_cgroup_charge_common+0x75/0xa0
[  173.233252]  [<ffffffff802df74d>] ? rw_copy_check_uvector+0x9d/0x150
[  173.233252]  [<ffffffff802e0062>] ? do_readv_writev+0xe2/0x220
[  173.233252]  [<ffffffff8022cc35>] ? default_spin_lock_flags+0x5/0x10
[  173.233252]  [<ffffffff804de09e>] ? _spin_lock_irqsave+0x2e/0x40
[  173.233252]  [<ffffffff804e0ae3>] ? do_page_fault+0x523/0xaa0
[  173.233252]  [<ffffffff804de09e>] ? _spin_lock_irqsave+0x2e/0x40
[  173.233252]  [<ffffffff802e0693>] ? sys_writev+0x53/0xc0
[  173.233252]  [<ffffffff8021252a>] ? system_call_fastpath+0x16/0x1b
[  173.233252] Code: c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 41 57 41 56 41 89 f6 41 55 41 54 41 89 cc 55 53 48 83 ec 28 48 89 7c 24 18 48 89 54 24 10 <8b> 6f 68 2b 6f 6c 89 e8 29 f0 85 c0 0f 8f 6f 01 00 00 48 8b 4c 
[  173.233252] RIP  [<ffffffff8044875e>] skb_copy_datagram_from_iovec+0x1e/0x260
[  173.233252]  RSP <ffff880827cbfc68>
[  173.233252] CR2: ffffffffffff8871
[  173.233252] ---[ end trace efbfb68cafc813b4 ]---

[  298.181441] general protection fault: 0000 [#2] SMP 
[  298.184002] last sysfs file: /sys/kernel/uevent_seqnum
[  298.184002] CPU 0 
[  298.184002] Modules linked in: tun nfs lockd nfs_acl auth_rpcgss sunrpc iptable_filter ip_tables ebtable_broute bridge stp ebtable_nat ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf hpilo ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support hpwdt i5000_edac serio_raw edac_core psmouse pcspkr shpchp button container i5k_amb pci_hotplug joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod ehci_hcd uhci_hcd lpfc scsi_transport_fc usbcore cciss scsi_tgt scsi_mod bnx2 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
[  298.184002] Pid: 6822, comm: qemu-system-x86 Tainted: G      D    2.6.29-rc3 #4
[  298.184002] RIP: 0010:[<ffffffff8044144a>]  [<ffffffff8044144a>] sock_alloc_send_pskb+0x7a/0x2c0
[  298.184002] RSP: 0018:ffff880828dc5c48  EFLAGS: 00010217
[  298.184002] RAX: 1f00ffffffffffff RBX: ffff88082036fd80 RCX: 0000000000000800
[  298.184002] RDX: 0000000000000000 RSI: 0000000000000148 RDI: ffff88082036fd80
[  298.184002] RBP: 0000000000000000 R08: ffff880828dc5cf4 R09: 0000000000000000
[  298.184002] R10: 0000000000000000 R11: ffffffff80350440 R12: ffff880828dc5c58
[  298.184002] R13: ffff880828dc5c70 R14: 00000000e9291f00 R15: 0000000000000000
[  298.184002] FS:  00007f5e2e9c46e0(0000) GS:ffffffff80797000(0000) knlGS:0000000000000000
[  298.184002] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  298.184002] CR2: 00007fff369c6f90 CR3: 00000007df827000 CR4: 00000000000006e0
[  298.184002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  298.184002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  298.184002] Process qemu-system-x86 (pid: 6822, threadinfo ffff880828dc4000, task ffff88081f7d0650)
[  298.184002] Stack:
[  298.184002]  ffff880828dc5cf4 0000000000000148 ffff880828915c78 ffffe2001bdc76c8
[  298.184002]  000000000000001e 000000000000001e ffff880000001d90 0000000000000002
[  298.184002]  000000004991c589 0000000000000800 ffffffffa047f410 0000000000000148
[  298.184002] Call Trace:
[  298.184002]  [<ffffffffa047f410>] tun_chr_aio_write+0x0/0x440 [tun]
[  298.184002]  [<ffffffffa047f554>] tun_chr_aio_write+0x144/0x440 [tun]
[  298.184002]  [<ffffffff802b68ad>] zone_statistics+0x7d/0x80
[  298.184002]  [<ffffffffa047f410>] tun_chr_aio_write+0x0/0x440 [tun]
[  298.184002]  [<ffffffff802df90b>] do_sync_readv_writev+0xcb/0x110
[  298.184002]  [<ffffffff80261f90>] autoremove_wake_function+0x0/0x30
[  298.184002]  [<ffffffff802dcf25>] mem_cgroup_charge_common+0x75/0xa0
[  298.184002]  [<ffffffff802df74d>] rw_copy_check_uvector+0x9d/0x150
[  298.184002]  [<ffffffff802e0062>] do_readv_writev+0xe2/0x220
[  298.184002]  [<ffffffff8022cc35>] default_spin_lock_flags+0x5/0x10
[  298.184002]  [<ffffffff804de09e>] _spin_lock_irqsave+0x2e/0x40
[  298.184002]  [<ffffffff804e0ae3>] do_page_fault+0x523/0xaa0
[  298.184002]  [<ffffffff804de09e>] _spin_lock_irqsave+0x2e/0x40
[  298.184002]  [<ffffffff802e0693>] sys_writev+0x53/0xc0
[  298.184002]  [<ffffffff8021252a>] system_call_fastpath+0x16/0x1b
[  298.184002] Code: 85 c0 0f 85 fb 00 00 00 f6 43 38 02 0f 85 09 01 00 00 8b 83 98 00 00 00 3b 83 a0 00 00 00 0f 8c 16 01 00 00 48 8b 83 e0 01 00 00 <f0> 80 48 08 01 48 8b 83 e0 01 00 00 f0 80 48 08 04 48 85 ed 0f 
[  298.184002] RIP  [<ffffffff8044144a>] sock_alloc_send_pskb+0x7a/0x2c0
[  298.184002]  RSP <ffff880828dc5c48>
[  298.314428] ---[ end trace efbfb68cafc813b5 ]---

[  490.120309] BUG: unable to handle kernel NULL pointer dereference at 00000000000000f8
[  490.121002] IP: [<ffffffff804413ed>] sock_alloc_send_pskb+0x1d/0x2c0
[  490.121002] PGD 7df826067 PUD 8234fd067 PMD 0 
[  490.121002] Oops: 0000 [#3] SMP 
[  490.121002] last sysfs file: /sys/kernel/uevent_seqnum
[  490.121002] CPU 4 
[  490.121002] Modules linked in: tun nfs lockd nfs_acl auth_rpcgss sunrpc iptable_filter ip_tables ebtable_broute bridge stp ebtable_nat ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc lp parport loop af_packet ipmi_devintf hpilo ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support hpwdt i5000_edac serio_raw edac_core psmouse pcspkr shpchp button container i5k_amb pci_hotplug joydev evdev ext3 jbd mbcache usbhid hid sg sd_mod ehci_hcd uhci_hcd lpfc scsi_transport_fc usbcore cciss scsi_tgt scsi_mod bnx2 dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan thermal_sys fuse
[  490.121002] Pid: 6864, comm: qemu-system-x86 Tainted: G      D    2.6.29-rc3 #4
[  490.121002] RIP: 0010:[<ffffffff804413ed>]  [<ffffffff804413ed>] sock_alloc_send_pskb+0x1d/0x2c0
[  490.121002] RSP: 0018:ffff88081f4f1c48  EFLAGS: 00010296
[  490.121002] RAX: 0000000000000002 RBX: 0000000000000000 RCX: 0000000000000800
[  490.121002] RDX: 0000000000000000 RSI: 0000000000000148 RDI: 0000000000000000
[  490.121002] RBP: ffffffffa047f410 R08: ffff88081f4f1cf4 R09: 0000000000000000
[  490.121002] R10: 0000000000000000 R11: ffffffff80350440 R12: 0000000000000148
[  490.121002] R13: ffff880823575240 R14: 0000000000000156 R15: 0000000000000000
[  490.121002] FS:  00007f9436fce6e0(0000) GS:ffff88082bfe0d80(0000) knlGS:0000000000000000
[  490.121002] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  490.121002] CR2: 00000000000000f8 CR3: 000000081f4a8000 CR4: 00000000000006e0
[  490.121002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  490.121002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  490.121002] Process qemu-system-x86 (pid: 6864, threadinfo ffff88081f4f0000, task ffff88081dc7e500)
[  490.121002] Stack:
[  490.121002]  ffff88081f4f1cf4 0000000000000148 00000000012f53da ffffe2001b9c05f8
[  490.121002]  000000000000001e 000000000000001e ffff880000001d90 0000000000000002
[  490.121002]  000000004991c649 0000000000000800 ffffffffa047f410 0000000000000148
[  490.121002] Call Trace:
[  490.121002]  [<ffffffffa047f410>] ? tun_chr_aio_write+0x0/0x440 [tun]
[  490.121002]  [<ffffffffa047f554>] ? tun_chr_aio_write+0x144/0x440 [tun]
[  490.121002]  [<ffffffff804ddf75>] ? _spin_lock+0x5/0x10
[  490.121002]  [<ffffffff802f0008>] ? sys_ppoll+0xe8/0x170
[  490.121002]  [<ffffffff804ddf75>] ? _spin_lock+0x5/0x10
[  490.121002]  [<ffffffffa047f410>] ? tun_chr_aio_write+0x0/0x440 [tun]
[  490.121002]  [<ffffffff802df90b>] ? do_sync_readv_writev+0xcb/0x110
[  490.121002]  [<ffffffff80261f90>] ? autoremove_wake_function+0x0/0x30
[  490.121002]  [<ffffffff80265380>] ? ktime_get_ts+0x20/0x60
[  490.121002]  [<ffffffff802653cc>] ? ktime_get+0xc/0x50
[  490.121002]  [<ffffffff802df74d>] ? rw_copy_check_uvector+0x9d/0x150
[  490.121002]  [<ffffffff802e0062>] ? do_readv_writev+0xe2/0x220
[  490.121002]  [<ffffffff802615fe>] ? sys_timer_settime+0x14e/0x340
[  490.121002]  [<ffffffff804de09e>] ? _spin_lock_irqsave+0x2e/0x40
[  490.121002]  [<ffffffff802e0693>] ? sys_writev+0x53/0xc0
[  490.121002]  [<ffffffff8021252a>] ? system_call_fastpath+0x16/0x1b
[  490.121002] Code: 00 00 5b 48 89 d0 c3 0f 1f 80 00 00 00 00 41 57 49 89 d7 41 56 41 55 41 54 55 53 48 89 fb 48 83 ec 48 48 89 74 24 08 4c 89 04 24 <44> 8b b7 f8 00 00 00 44 89 f0 80 cc 04 41 f6 c6 10 44 0f 45 f0 
[  490.121002] RIP  [<ffffffff804413ed>] sock_alloc_send_pskb+0x1d/0x2c0
[  490.121002]  RSP <ffff88081f4f1c48>
[  490.121002] CR2: 00000000000000f8
[  490.259999] ---[ end trace efbfb68cafc813b6 ]---


