From: "Jann Traschewski" <jann@gmx.de>
Subject: [BUG][AX25] spinlock lockup
Date: Sun, 24 Feb 2008 04:10:29 +0100
Message-ID: <001a01c87692$cfca8d00$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Ralf Baechle'" <ralf@linux-mips.org>
To: <netdev@vger.kernel.org>, "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:42143 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751001AbYBXDKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Feb 2008 22:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I got a "spinlock lockup" using the latest Kernel 2.6.24.2 with recent
patches from Jarek Poplawski applied.


 ppp_deflate nf_nat zlib_deflateBUG: unable to handle kernel NULL pointer
dereference zlib_inflate nf_conntrack_ipv4 bsd_comp slhc ppp_async xt_state
tun ppp_genericprinting eip: c02338c2  nf_conntrack bitrev ipt_REJECT*pde =
00000000  iptable_filter crc32
 iptable_mangle mkiss xt_MARK at virtual address 00000004
 ax25 ipv6Oops: 0002 [#1] SMP  ipip crc16
 tunnel4Modules linked in: iptable_nat ide_cd cdrom aic7xxx
scsi_transport_spi parport_serial parport_pc parport i2c_piix4 netconsole
genrtc

Pid: 3032, comm: linuxnet Not tainted (2.6.24.2-dg8ngn-p02 #1)
EIP: 0060:[<c02338c2>] EFLAGS: 00010092 CPU: 0
EIP is at skb_append+0x1b/0x30
EAX: 00000292 EBX: c9318980 ECX: c0466a80 EDX: 00000000
ESI: c9e085c0 EDI: f40846ac EBP: f40846b8 ESP: f72cbd04
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process linuxnet (pid: 3032, ti=f72ca000 task=f7d08030 task.ti=f72ca000)
Stack: c9318980 c9e085c0 f4084600 00000000 f8a0e2a3 f4084600 00000005
00000010 BUG: spinlock lockup on CPU#1, bcm/12213, f40846b8
Pid: 12213, comm: bcm Tainted: G      D 2.6.24.2-dg8ngn-p02 #1
 [<c01cb96f>] _raw_spin_lock+0xbb/0xdc
 [<c0299fdc>] _spin_lock_irqsave+0x39/0x41
 [<c02339bf>] skb_dequeue+0xf/0x3f
 [<c02339bf>] skb_dequeue+0xf/0x3f
 [<f8a0c998>] ax25_kick+0x14f/0x18c [ax25]
 [<f8a10a26>] ax25_sendmsg+0x35f/0x49a [ax25]
 [<c01473d1>] file_read_actor+0x7d/0xd5
 [<c0147c35>] do_generic_mapping_read+0x1d5/0x3b2
 [<c0147354>] file_read_actor+0x0/0xd5
 [<c022e404>] sock_aio_write+0xbf/0xcb
 [<c01494ba>] generic_file_aio_read+0x161/0x19c
 [<c01627bb>] do_sync_write+0xc7/0x10a
 [<c0130ea9>] autoremove_wake_function+0x0/0x35
 [<c0162f48>] vfs_write+0x9e/0x10c
 [<c01634b0>] sys_write+0x41/0x67
 [<c0103ea2>] syscall_call+0x7/0xb
 =======================


--
Jann Traschewski, Drosselstr.1, D-90513 Zirndorf, Germany
Tel.: +49-911-696971, Mobile: +49-170-1045937, EMail: jann@gmx.de
Ham: DG8NGN / DB0VOX, http://www.qsl.net/db0fhn, ICQ UIN: 4130182 

