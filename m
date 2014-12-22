From: Wolfgang Walter <linux@stwm.de>
Subject: OOPS: unable to handle kernel NULL pointer dereference in unix_detach_fds
Date: Mon, 22 Dec 2014 21:52:14 +0100
Message-ID: <13543468.F7vemBIeOc@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:41601 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754910AbaLVUwR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 15:52:17 -0500
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 3k5tCg00Qzz2hYg
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 21:52:15 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

today I saw this oops with kernel 3.18.1:

Dec 22 14:30:26 hobel kernel: [   37.476849] BUG: unable to handle kern=
el NULL pointer dereference at 0000000000000001
Dec 22 14:30:26 hobel kernel: [   37.476856] IP: [<ffffffff81a7c70c>] u=
nix_detach_fds.isra.28+0x1c/0x50
Dec 22 14:30:26 hobel kernel: [   37.476862] PGD a90ab067 PUD a8d2c067 =
PMD 0=20
Dec 22 14:30:26 hobel kernel: [   37.476866] Oops: 0000 [#1] PREEMPT SM=
P=20
Dec 22 14:30:26 hobel kernel: [   37.476868] Modules linked in: bnep bl=
uetooth rfkill vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) nfsd x=
t_conntrack xt_socket xt_helper nf_conntrack_tftp nf_conntrack_snmp nf_=
conntrack_broadcast nf_conntrack_sip nf_conntrack_irc nf_conntrack_h323=
 nf_conntrack_ftp nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf=
_defrag_ipv4 nf_conntrack uvcvideo videobuf2_vmalloc snd_usb_audio snd_=
hwdep snd_usbmidi_lib snd_rawmidi nvidia(PO) i2c_piix4
Dec 22 14:30:26 hobel kernel: [   37.476887] CPU: 4 PID: 2234 Comm: pla=
sma-desktop Tainted: P           O   3.18.1-ei+6.9 #2
Dec 22 14:30:26 hobel kernel: [   37.476890] Hardware name: System manu=
facturer System Product Name/M4A89GTD-PRO/USB3, BIOS 1104    03/12/2010
Dec 22 14:30:26 hobel kernel: [   37.476892] task: ffff88022aa2e320 ti:=
 ffff8800aebec000 task.ti: ffff8800aebec000
Dec 22 14:30:26 hobel kernel: [   37.476894] RIP: 0010:[<ffffffff81a7c7=
0c>]  [<ffffffff81a7c70c>] unix_detach_fds.isra.28+0x1c/0x50
Dec 22 14:30:26 hobel kernel: [   37.476897] RSP: 0018:ffff8800aebefb68=
  EFLAGS: 00010202
Dec 22 14:30:26 hobel kernel: [   37.476898] RAX: 0000000000000001 RBX:=
 0000000040000040 RCX: 00000000000000f0
Dec 22 14:30:26 hobel kernel: [   37.476900] RDX: 0000000000000006 RSI:=
 ffff880206110300 RDI: ffff8800aebefc18
Dec 22 14:30:26 hobel kernel: [   37.476901] RBP: ffff8800aebefb78 R08:=
 0000000000000000 R09: ffff88022f001700
Dec 22 14:30:26 hobel kernel: [   37.476902] R10: ffff880206110300 R11:=
 00000000000000f0 R12: ffff8800aebefc18
Dec 22 14:30:26 hobel kernel: [   37.476904] R13: 0000000000000000 R14:=
 ffff8802076a2710 R15: ffff880206110300
Dec 22 14:30:26 hobel kernel: [   37.476906] FS:  00007f3a37991800(0000=
) GS:ffff880237d00000(0000) knlGS:0000000000000000
Dec 22 14:30:26 hobel kernel: [   37.476907] CS:  0010 DS: 0000 ES: 000=
0 CR0: 0000000080050033
Dec 22 14:30:26 hobel kernel: [   37.476909] CR2: 0000000000000001 CR3:=
 00000000a9190000 CR4: 00000000000007e0
Dec 22 14:30:26 hobel kernel: [   37.476910] Stack:
Dec 22 14:30:26 hobel kernel: [   37.476911]  0000000040000040 ffff8802=
076a2680 ffff8800aebefc88 ffffffff81a7caec
Dec 22 14:30:26 hobel kernel: [   37.476914]  ffff8800a8d0ba01 ffff8802=
2aa2e320 ffff8800aebefc48 ffff88022aa2e320
Dec 22 14:30:26 hobel kernel: [   37.476916]  ffff8802076a2938 00000001=
0000000d 0000000000000000 0000000700000000
Dec 22 14:30:26 hobel kernel: [   37.476918] Call Trace:
Dec 22 14:30:26 hobel kernel: [   37.476922]  [<ffffffff81a7caec>] unix=
_stream_recvmsg+0x32c/0x870
Dec 22 14:30:26 hobel kernel: [   37.476925]  [<ffffffff81a7dedb>] ? un=
ix_stream_sendmsg+0x3fb/0x430
Dec 22 14:30:26 hobel kernel: [   37.476928]  [<ffffffff819416ae>] sock=
_recvmsg+0x6e/0x90
Dec 22 14:30:26 hobel kernel: [   37.476931]  [<ffffffff81201280>] ? po=
ll_select_copy_remaining+0x130/0x130
Dec 22 14:30:26 hobel kernel: [   37.476933]  [<ffffffff81201280>] ? po=
ll_select_copy_remaining+0x130/0x130
Dec 22 14:30:26 hobel kernel: [   37.476936]  [<ffffffff819501a2>] ? ve=
rify_iovec+0x42/0xd0
Dec 22 14:30:26 hobel kernel: [   37.476938]  [<ffffffff819427b6>] ___s=
ys_recvmsg+0x106/0x2e0
Dec 22 14:30:26 hobel kernel: [   37.476941]  [<ffffffff81201280>] ? po=
ll_select_copy_remaining+0x130/0x130
Dec 22 14:30:26 hobel kernel: [   37.476943]  [<ffffffff8123078b>] ? ev=
entfd_ctx_read+0x1ab/0x220
Dec 22 14:30:26 hobel kernel: [   37.476946]  [<ffffffff81133e70>] ? wa=
ke_up_process+0x50/0x50
Dec 22 14:30:26 hobel kernel: [   37.476949]  [<ffffffff8120a704>] ? __=
fget+0x74/0xb0
Dec 22 14:30:26 hobel kernel: [   37.476952]  [<ffffffff8120a77f>] ? __=
fget_light+0x1f/0x80
Dec 22 14:30:26 hobel kernel: [   37.476954]  [<ffffffff81943e84>] __sy=
s_recvmsg+0x44/0x80
Dec 22 14:30:26 hobel kernel: [   37.476957]  [<ffffffff81943ecd>] SyS_=
recvmsg+0xd/0x20
Dec 22 14:30:26 hobel kernel: [   37.476961]  [<ffffffff81b34c69>] syst=
em_call_fastpath+0x12/0x17
Dec 22 14:30:26 hobel kernel: [   37.476962] Code: ff ff 48 8b 5d f0 4c=
 8b 65 f8 c9 c3 0f 1f 00 55 48 8b 46 38 48 89 e5 41 54 49 89 fc 53 48 8=
9 07 48 c7 46 38 00 00 00 00 48 8b 07 <0f> bf 18 ff cb 79 09 eb 1b 0f 1=
f 00 49 8b 04 24 48 63 d3 ff cb=20
Dec 22 14:30:26 hobel kernel: [   37.476983] RIP  [<ffffffff81a7c70c>] =
unix_detach_fds.isra.28+0x1c/0x50
Dec 22 14:30:26 hobel kernel: [   37.476985]  RSP <ffff8800aebefb68>
Dec 22 14:30:26 hobel kernel: [   37.476986] CR2: 0000000000000001
Dec 22 14:30:26 hobel kernel: [   37.476988] ---[ end trace 05163e1048a=
933ce ]---

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
