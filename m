From: Dave Jones <davej@redhat.com>
Subject: NULL pointer dereference at __ip_route_output_key
Date: Mon, 2 Apr 2012 15:40:56 -0400
Message-ID: <20120402194056.GA1002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772Ab2DBTk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 15:40:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just had this reported. Look familiar to anyone ?

:BUG: unable to handle kernel NULL pointer dereference at 00000000000000d0
:IP: [<ffffffff81518d73>] __ip_route_output_key+0x703/0x9f0
:PGD 0 
:Oops: 0000 [#1] SMP 
:CPU 0 
:Modules linked in: fuse ppdev parport_pc lp parport ebtable_nat ebtables
ipt_MASQUERADE iptable_nat nf_nat xt_CHECKSUM iptable_mangle bridge stp llc
lockd be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi
cxgb3 mdio ib_iser rdma_cm ib_cm iw_cm ib_sa ib_addr iscsi_tcp libiscsi_tcp
libiscsi scsi_transport_iscsi ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
ip6table_filter nf_conntrack_ipv4 ip6_tables nf_defrag_ipv4 xt_state
nf_conntrack usblp joydev raid10 binfmt_misc snd_hda_codec_hdmi
snd_hda_codec_realtek microcode sp5100_tco snd_hda_intel k10temp snd_hda_codec
serio_raw i2c_piix4 snd_hwdep snd_seq edac_core vhost_net edac_mce_amd
snd_seq_device macvtap macvlan tun virtio_net snd_pcm ib_qib kvm_amd snd_timer
snd kvm r8169 ib_mad soundcore snd_page_alloc ib_core mii uinput sunrpc
firewire_ohci ata_generic firewire_core pata_acpi crc_itu_t pata_atiixp wmi
usb_storage radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded:
scsi_wait_scan]
:Pid: 3269, comm: sendmail Not tainted 3.3.0-8.fc16.x86_64 #1 Gigabyte
Technology Co., Ltd. GA-MA790X-UD4/GA-MA790X-UD4
:RIP: 0010:[<ffffffff81518d73>]  [<ffffffff81518d73>]
__ip_route_output_key+0x703/0x9f0
:RSP: 0018:ffff880128be1da8  EFLAGS: 00010246
:RAX: 0000000000000000 RBX: ffff88010adda970 RCX: 0000000000000000
:RDX: 00000000017aa8c0 RSI: ffff880117ac2000 RDI: ffff880121ab6000
:RBP: ffff880128be1e38 R08: 0000000000000001 R09: 0000000000000000
:R10: ffff880123095480 R11: ffff880107e91b40 R12: 0000000000000000
:R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
:FS:  00007f4ad68ae7c0(0000) GS:ffff88012fc00000(0000) knlGS:0000000000000000
:CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
:CR2: 00000000000000d0 CR3: 0000000102ef1000 CR4: 00000000000006f0
:DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
:DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
:Process sendmail (pid: 3269, threadinfo ffff880128be0000, task
ffff88009e48c590)
:Stack:
: 00000000fe07dd09 ffff88010adda680 b7da880128be1ed0 ffffffff81544440
: ffffffff81f74200 f1281bd40adda680 ffff880128be1e38 0000000000010000
: ffff880107e91b40 ffff880123095480 ffff880123307698 ffff880129693540
:Call Trace:
: [<ffffffff81544440>] ? udp_lib_lport_inuse+0xf0/0xf0
: [<ffffffff81542717>] ip4_datagram_connect+0x167/0x300
: [<ffffffff8154fca1>] inet_dgram_connect+0x31/0x90
: [<ffffffff814d156b>] sys_connect+0xeb/0x110
: [<ffffffff8117f98b>] ? fd_install+0x3b/0x70
: [<ffffffff810d347c>] ? __audit_syscall_entry+0xcc/0x310
: [<ffffffff810d3a96>] ? __audit_syscall_exit+0x3d6/0x410
: [<ffffffff814d0e40>] ? sys_socket+0x40/0x70
: [<ffffffff815fbca9>] system_call_fastpath+0x16/0x1b
:Code: 01 7e 08 3c 01 0f 84 d7 02 00 00 8b 53 14 85 d2 0f 84 aa 01 00 00 0f b6
45 a9 48 8d 04 c0 44 0f b6 45 aa 45 31 ff 4d 8b 64 c3 60 <41> 8b 84 24 d0 00 00
00 89 03 0f b6 c2 e9 a7 fa ff ff 31 d2 44 


https://bugzilla.redhat.com/show_bug.cgi?id=808990
