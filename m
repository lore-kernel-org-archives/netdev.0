From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [BUG] 2.6.32.21 bnx2_napi->hw_tx_cons_ptr NULL pointer dereference
Date: Wed, 8 Sep 2010 17:44:47 -0500
Message-ID: <20100908224447.GA4979@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47005 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257Ab0IHWo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 18:44:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

While testing 2.6.32.21 I had the following Oops occur on one of my
machines:


Sep  8 12:32:01 dev4 kernel: tcp_v4_hash_offload: sk=ffff88081ba0cb00
Sep  8 12:32:01 dev4 kernel: svc: failed to register lockdv1 RPC service (errno 97).
Sep  8 12:32:04 dev4 sshd[15072]: Accepted publickey for hbi from 10.0.4.17 port 60687 ssh2
Sep  8 12:33:03 dev4 sshd[15096]: Accepted publickey for hbi from 10.0.4.17 port 60931 ssh2
Sep  8 12:34:03 dev4 sshd[15118]: Accepted publickey for hbi from 10.0.4.17 port 32929 ssh2
Sep  8 12:35:03 dev4 sshd[15141]: Accepted publickey for hbi from 10.0.4.17 port 40107 ssh2
Sep  8 12:36:03 dev4 sshd[15166]: Accepted publickey for hbi from 10.0.4.17 port 40361 ssh2
Sep  8 12:37:02 dev4 sshd[15191]: Connection closed by 10.0.0.104
Sep  8 12:37:03 dev4 sshd[15192]: Accepted publickey for hbi from 10.0.4.17 port 40642 ssh2
Sep  8 12:38:01 dev4 kernel: tcp_v4_hash_offload: sk=ffff88082f1d5900
Sep  8 12:38:01 dev4 kernel: svc: failed to register lockdv1 RPC service (errno 97).
Sep  8 12:38:01 dev4 kernel: BUG: unable to handle kernel NULL pointer dereference at (null)
Sep  8 12:38:01 dev4 kernel: IP: [<ffffffffa039390a>] bnx2_poll_work+0x3a/0x1140 [bnx2]
Sep  8 12:38:01 dev4 kernel: PGD 0 
Sep  8 12:38:01 dev4 kernel: Oops: 0000 [#1] SMP 
Sep  8 12:38:01 dev4 kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:06.0/0000:0c:00.0/irq
Sep  8 12:38:01 dev4 kernel: CPU 0 
Sep  8 12:38:01 dev4 kernel: Modules linked in: ipmi_si mptctl mptbase ipmi_devintf ipmi_msghandler dell_rbu nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 netconsole configfs autofs4 fuse ext3 jbd mbcache dm_mirror dm_multipath scsi_dh video output sbs sbshc acpi_pad parport_pc lp parport joydev t3_tom ses enclosure bnx2 sg toecore cxgb3 radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core sr_mod cdrom pata_acpi i5k_amb ata_generic hwmon iTCO_wdt iTCO_vendor_support i5000_edac edac_core serio_raw snd_pcm dcdbas snd_timer snd soundcore snd_page_alloc pcspkr dm_region_hash dm_log dm_mod ata_piix libata shpchp megaraid_sas sd_mod crc_t10dif scsi_mod xfs exportfs uhci_hcd ohci_hcd ssb mmc_core ehci_hcd [last unloaded: ipmi_si]
Sep  8 12:38:01 dev4 kernel: Pid: 15224, comm: mount.nfs Not tainted 2.6.32.21-1.rgm #1 PowerEdge 1950
Sep  8 12:38:01 dev4 kernel: RIP: 0010:[<ffffffffa039390a>]  [<ffffffffa039390a>] bnx2_poll_work+0x3a/0x1140 [bnx2]
Sep  8 12:38:01 dev4 kernel: RSP: 0018:ffff88081ba033f8  EFLAGS: 00010092
Sep  8 12:38:01 dev4 kernel: RAX: 0000000000000000 RBX: ffff88085b1a9800 RCX: 0000000000000010
Sep  8 12:38:01 dev4 kernel: RDX: ffff88085b1a9800 RSI: ffff88085b1a9800 RDI: ffff88085b1a85c0
Sep  8 12:38:01 dev4 kernel: RBP: ffff88081ba034f8 R08: 0000000000000000 R09: 0000000000000000
Sep  8 12:38:01 dev4 kernel: R10: 0000000000000000 R11: 0000000000000006 R12: 0000000000000010
Sep  8 12:38:01 dev4 kernel: R13: ffff88085b1a85c0 R14: 0000000000000000 R15: ffff88085bbac240
Sep  8 12:38:01 dev4 kernel: FS:  00007fb00eb566e0(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
Sep  8 12:38:01 dev4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Sep  8 12:38:01 dev4 kernel: CR2: 0000000000000000 CR3: 00000008487e4000 CR4: 00000000000406f0
Sep  8 12:38:01 dev4 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  8 12:38:01 dev4 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep  8 12:38:01 dev4 kernel: Process mount.nfs (pid: 15224, threadinfo ffff88081ba02000, task ffff880821000700)
Sep  8 12:38:01 dev4 kernel: Stack:
Sep  8 12:38:01 dev4 kernel:  ffff880857852800 ffff88085b751400 0000000000000001 00000000000003f0
Sep  8 12:38:01 dev4 kernel: <0> 000000001ba03518 ffffffff8123aa4b 0000000000000010 0000000000000000
Sep  8 12:38:01 dev4 kernel: <0> ffff88081ba03458 ffffffff8121ef00 ffff88085b1a9800 ffff880857c5f600
Sep  8 12:38:01 dev4 kernel: Call Trace:
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8123aa4b>] ? bit_cursor+0x65b/0x6c0
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8121ef00>] ? msi_set_mask_bit+0x80/0x90
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8121ef20>] ? unmask_msi_irq+0x10/0x20
Sep  8 12:38:01 dev4 kernel:  [<ffffffff810b0c69>] ? default_enable+0x29/0x40
Sep  8 12:38:01 dev4 kernel:  [<ffffffff810b0abc>] ? check_irq_resend+0x2c/0x80
Sep  8 12:38:01 dev4 kernel:  [<ffffffff810af7eb>] ? __enable_irq+0x7b/0x90
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0394a4d>] bnx2_poll_msix+0x3d/0xc0 [bnx2]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0391703>] ? poll_bnx2+0x63/0x80 [bnx2]
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8136a9b7>] netpoll_poll+0xd7/0x420
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8136aea3>] netpoll_send_skb+0x113/0x200
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8136b19f>] netpoll_send_udp+0x20f/0x220
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa04a52c3>] write_msg+0xc3/0x110 [netconsole]
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8105b935>] __call_console_drivers+0x75/0x90
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8105b99a>] _call_console_drivers+0x4a/0x80
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8105bf60>] release_console_sem+0xf0/0x210
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8105c599>] vprintk+0x1b9/0x4e0
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8141905e>] printk+0x41/0x43
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa051df8f>] svc_register+0xdf/0x2b0 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0521364>] svc_setup_socket+0xa4/0x360 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa05217ab>] svc_create_socket+0x18b/0x2c0 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0525490>] ? rpcb_register_call+0x90/0xf0 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa05218fb>] svc_udp_create+0x1b/0x20 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa052c635>] svc_create_xprt+0x175/0x2a0 [sunrpc]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0591ea5>] create_lockd_listener+0x75/0x80 [lockd]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0591ee1>] create_lockd_family+0x31/0x60 [lockd]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa0591fc2>] lockd_up+0xb2/0x210 [lockd]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa058f69d>] nlmclnt_init+0x1d/0x70 [lockd]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa05aa74a>] nfs_start_lockd+0x8a/0xc0 [nfs]
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa05ac732>] nfs_create_server+0x162/0x650 [nfs]
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8114d159>] ? mntput_no_expire+0x29/0xf0
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8112484c>] ? pcpu_alloc_area+0x23c/0x340
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8112425e>] ? pcpu_next_pop+0x4e/0x70
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8112579a>] ? pcpu_alloc+0x3ea/0xa30
Sep  8 12:38:01 dev4 kernel:  [<ffffffffa05b8622>] nfs_get_sb+0x3e2/0x990 [nfs]
Sep  8 12:38:01 dev4 kernel:  [<ffffffff81132b4b>] vfs_kern_mount+0x7b/0x1b0
Sep  8 12:38:01 dev4 kernel:  [<ffffffff81132cf2>] do_kern_mount+0x52/0x130
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8114f995>] do_mount+0x2d5/0x850
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8114ffa8>] sys_mount+0x98/0xf0
Sep  8 12:38:01 dev4 kernel:  [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
Sep  8 12:38:01 dev4 kernel: Code: ec d8 00 00 00 0f 1f 44 00 00 48 89 b5 50 ff ff ff 89 95 24 ff ff ff 49 89 fd 89 8d 30 ff ff ff 48 8b 95 50 ff ff ff 48 8b 42 70 <0f> b7 00 3c ff 0f 84 e2 10 00 00 48 8b 8d 50 ff ff ff 66 39 81 
Sep  8 12:38:01 dev4 kernel: RIP  [<ffffffffa039390a>] bnx2_poll_work+0x3a/0x1140 [bnx2]
Sep  8 12:38:01 dev4 kernel:  RSP <ffff88081ba033f8>
Sep  8 12:38:01 dev4 kernel: CR2: 0000000000000000
Sep  8 12:38:01 dev4 kernel: ---[ end trace 8f10ffb4a2f96c8d ]---


All code
========
   0:   ec                      in     (%dx),%al
   1:   d8 00                   fadds  (%rax)
   3:   00 00                   add    %al,(%rax)
   5:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
   a:   48 89 b5 50 ff ff ff    mov    %rsi,0xffffffffffffff50(%rbp)
  11:   89 95 24 ff ff ff       mov    %edx,0xffffffffffffff24(%rbp)
  17:   49 89 fd                mov    %rdi,%r13
  1a:   89 8d 30 ff ff ff       mov    %ecx,0xffffffffffffff30(%rbp)
  20:   48 8b 95 50 ff ff ff    mov    0xffffffffffffff50(%rbp),%rdx
  27:   48 8b 42 70             mov    0x70(%rdx),%rax
  2b:*  0f b7 00                movzwl (%rax),%eax     <-- trapping instruction
  2e:   3c ff                   cmp    $0xff,%al
  30:   0f 84 e2 10 00 00       je     0x1118
  36:   48 8b 8d 50 ff ff ff    mov    0xffffffffffffff50(%rbp),%rcx
  3d:   66                      data16
  3e:   39                      .byte 0x39
  3f:   81                      .byte 0x81

Code starting with the faulting instruction
===========================================
   0:   0f b7 00                movzwl (%rax),%eax
   3:   3c ff                   cmp    $0xff,%al
   5:   0f 84 e2 10 00 00       je     0x10ed
   b:   48 8b 8d 50 ff ff ff    mov    0xffffffffffffff50(%rbp),%rcx
  12:   66                      data16
  13:   39                      .byte 0x39
  14:   81                      .byte 0x81


I'm not sure if the:

svc: failed to register lockdv1 RPC service (errno 97).

messages are related, but I get those regularly and the crash appears
to have happened when mounting nfs.  I looked a little closer and the
NULL pointer that is getting dereferenced appears to be the
bnx2_napi->hw_tx_cons_ptr though that is as far as I looked.  Let me
know if there is any other useful information I can provide.

Thanks,
Shawn
