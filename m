From: Dave Jones <davej@redhat.com>
Subject: 3.5.1 fib_rules_lookup oops
Date: Mon, 20 Aug 2012 12:44:28 -0400
Message-ID: <20120820164428.GA27910@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514Ab2HTQod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 12:44:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just had a user report this, which I don't think I've seen reported here yet.
Something new, or just something missing from -stable ?

	Dave


BUG: unable to handle kernel paging request at 5f726571
IP: [<c0884808>] fib_rules_lookup+0x38/0x130
*pdpt = 000000002b8ef001 *pde = 0000000000000000 
Oops: 0000 [#1] SMP 
Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv4 nf_defrag_ipv6 xt_state ip6table_filter be2iscsi nf_conntrack iscsi_boot_sysfs ip6_tables bnx2i cnic uio cxgb4i it87 hwmon_vid cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi tpm_bios snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc vhost_net ppdev tun macvtap macvlan snd_timer parport_pc kvm_amd k8temp snd kvm forcedeth soundcore nv_tco parport i2c_nforce2 nfsd nfs_acl auth_rpcgss lockd uinput binfmt_misc sunrpc btrfs libcrc32c zlib_deflate firewire_ohci firewire_core ata_generic p
 ata_acpi crc_itu_t sata_nv pata_amd nouveau mxm_wmi wmi video i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]

Pid: 1943, comm: transmission-gt Not tainted 3.5.1-1.fc17.i686.PAE #1    /M55S-S3
EIP: 0060:[<c0884808>] EFLAGS: 00010a97 CPU: 0
EIP is at fib_rules_lookup+0x38/0x130
EAX: 5f726565 EBX: 5f726565 ECX: 00000000 EDX: c0b45a15
ESI: eb2f1d38 EDI: c0b45a59 EBP: eb2f1c44 ESP: eb2f1c24
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
CR0: 80050033 CR2: 5f726571 CR3: 33f3a000 CR4: 000007f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process transmission-gt (pid: 1943, ti=eb2f0000 task=f48bf110 task.ti=eb2f0000)
Stack:
 eb2f1c3c c0b45a59 00000000 c0b45a15 5f726565 eb2f1c90 eb2f1d38 c0be60c0
 eb2f1c64 c08dacc9 eb2f1c50 00000000 eb2f1c90 00000000 00000001 00000000
 eb2f1cb0 c089a2bc f75bc8c8 00000001 eb2f1c84 c066dd4f b4298b0e 00000001
Call Trace:
 [<c08dacc9>] fib_lookup+0x39/0x50
 [<c089a2bc>] __ip_route_output_key+0x5cc/0x8b0
 [<c066dd4f>] ? cpumask_next_and+0x1f/0x40
 [<c089a5bf>] ip_route_output_flow+0x1f/0x70
 [<c08c49bd>] udp_sendmsg+0x73d/0x8d0
 [<c08a0010>] ? ip_copy_metadata+0x140/0x140
 [<c08cd126>] inet_sendmsg+0x66/0xa0
 [<c0622d1f>] ? selinux_socket_sendmsg+0x1f/0x30
 [<c085c230>] sock_sendmsg+0xc0/0xf0
 [<c0410e71>] ? __switch_to+0xc1/0x270
 [<c047fce2>] ? idle_balance+0x102/0x150
 [<c0679dd1>] ? _copy_from_user+0x41/0x60
 [<c085c5a3>] ? move_addr_to_kernel+0x43/0x90
 [<c085cf0d>] sys_sendto+0xfd/0x140
 [<c046aa70>] ? update_rmtp+0x90/0x90
 [<c046b956>] ? hrtimer_start_range_ns+0x26/0x30
 [<c0589afb>] ? sys_epoll_wait+0x6b/0x370
 [<c085d921>] sys_socketcall+0x1d1/0x2d0
 [<c09672df>] sysenter_do_call+0x12/0x28
Code: 00 89 45 ec 89 d6 89 c2 8b 40 44 89 d7 83 c7 44 89 4d e8 89 45 f0 8b 5d f0 39 fb 0f 84 a3 00 00 00 89 7d e4 8d b4 26 00 00 00 00 <8b> 53 0c 85 d2 74 31 31 c0 3b 56 04 74 2a f6 43 20 02 74 08 85 
EIP: [<c0884808>] fib_rules_lookup+0x38/0x130 SS:ESP 0068:eb2f1c24
