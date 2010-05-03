From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Mon, 3 May 2010 14:00:48 -0700
Message-ID: <20100503140048.30aedad7@nehalam>
References: <20100503094735.077c2af5@nehalam>
	<1272906266.2226.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54515 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755619Ab0ECVBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 17:01:04 -0400
In-Reply-To: <1272906266.2226.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 May 2010 19:04:26 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 03 mai 2010 =C3=A0 09:47 -0700, Stephen Hemminger a =C3=A9cr=
it :
> > I am getting occasional NULL pointer references with net-next kerne=
l.
> > No test, just usual stuff (like DNS).
> >=20
> > This is a new regression in net-next only.
> >=20
> >=20
> > [  674.929685] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000322
> > [  674.929691] IP: [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.929699] PGD 1bce2b067 PUD 1b80af067 PMD 0=20
> > [  674.929704] Oops: 0000 [#1] SMP=20
> > [  674.929708] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:0=
0/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
> > [  674.929712] CPU 2=20
> > [  674.929713] Modules linked in: autofs4 binfmt_misc ipt_MASQUERAD=
E iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_connt=
rack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp =
llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_co=
dec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_m=
ixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd=
_seq_midi_event snd_seq snd_timer snd_seq_device snd asus_atk0110 sound=
core psmouse snd_page_alloc serio_raw usbhid mvsas libsas floppy scsi_t=
ransport_sas sky2 e1000e
> > [  674.929764]=20
> > [  674.929767] Pid: 4358, comm: dnsmasq Not tainted 2.6.34-rc6-net =
#121 P6T DELUXE/System Product Name
> > [  674.929770] RIP: 0010:[<ffffffff813e97c1>]  [<ffffffff813e97c1>]=
 ip_cmsg_recv+0x31/0x2d0
> > [  674.929776] RSP: 0018:ffff8801bce27ac8  EFLAGS: 00010246
> > [  674.929778] RAX: 0000000000000000 RBX: ffff8801bde62500 RCX: 000=
0000000000000
> > [  674.929781] RDX: ffff8801bce27e48 RSI: ffff8801bde62500 RDI: fff=
f8801bce27f18
> > [  674.929784] RBP: ffff8801bce27b48 R08: 0000000000000640 R09: 000=
0000000000000
> > [  674.929787] R10: 0000000000000020 R11: 0000000000000246 R12: fff=
f8801bce27f18
> > [  674.929789] R13: ffff8801bce27f18 R14: 0000000000000000 R15: fff=
f8801bdbe8850
> > [  674.929793] FS:  00007fe37fbfd700(0000) GS:ffff880001e40000(0000=
) knlGS:0000000000000000
> > [  674.929796] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  674.929798] CR2: 0000000000000322 CR3: 00000001bce5c000 CR4: 000=
00000000006e0
> > [  674.929801] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [  674.929804] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [  674.929807] Process dnsmasq (pid: 4358, threadinfo ffff8801bce26=
000, task ffff8801bda54560)
> > [  674.929810] Stack:
> > [  674.929811]  0000000000000134 000000000000012c ffff8801bce27b48 =
ffffffff813b065b
> > [  674.929816] <0> ffff8801bce27b08 ffffffff8123ce8e ffff8801bdbe88=
00 ffff8801bce27dc8
> > [  674.929821] <0> ffff8801bce27b18 ffffffff81464612 ffff8801bce27b=
48 000000005eba1e95
> > [  674.929827] Call Trace:
> > [  674.929834]  [<ffffffff813b065b>] ? skb_copy_datagram_iovec+0x5b=
/0x2c0
> > [  674.929840]  [<ffffffff8123ce8e>] ? do_raw_spin_unlock+0x5e/0xb0
> > [  674.929845]  [<ffffffff81464612>] ? _raw_spin_unlock_bh+0x12/0x2=
0
> > [  674.929850]  [<ffffffff8140cf01>] udp_recvmsg+0x291/0x2b0
> > [  674.929856]  [<ffffffff81045190>] ? default_wake_function+0x0/0x=
10
> > [  674.929860]  [<ffffffff8141403a>] inet_recvmsg+0x4a/0x80
> > [  674.929866]  [<ffffffff813a3d2b>] sock_recvmsg+0xeb/0x120
> > [  674.929872]  [<ffffffff814388c0>] ? unix_dgram_sendmsg+0x5b0/0x6=
30
> > [  674.929878]  [<ffffffff81119e12>] ? link_path_walk+0x502/0xaf0
> > [  674.929882]  [<ffffffff813a3728>] ? sock_aio_write+0x138/0x150
> > [  674.929888]  [<ffffffff810ca88d>] ? find_get_page+0x1d/0xc0
> > [  674.929892]  [<ffffffff813af8a3>] ? verify_iovec+0x93/0x100
> > [  674.929897]  [<ffffffff813a52bc>] __sys_recvmsg+0x14c/0x2d0
> > [  674.929902]  [<ffffffff813a56f4>] sys_recvmsg+0x44/0x80
> > [  674.929908]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b
> > [  674.929910] Code: c4 80 48 89 5d e0 4c 89 6d f0 65 48 8b 04 25 2=
8 00 00 00 48 89 45 d8 31 c0 4c 89 65 e8 4c 89 75 f8 49 89 fd 48 8b 46 =
18 48 89 f3 <44> 0f b7 a0 22 03 00 00 41 f6 c4 01 74 4b 48 8b 46 58 8b =
96 c4=20
> > [  674.929955] RIP  [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.929959]  RSP <ffff8801bce27ac8>
> > [  674.929961] CR2: 0000000000000322
> > [  674.929964] ---[ end trace 443be32e81365554 ]---
> > [  674.929966] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000322
> > [  674.929972] IP: [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.929979] PGD 1bb9c7067 PUD 1bd5d3067 PMD 0=20
> > [  674.929985] Oops: 0000 [#2] SMP=20
> > [  674.929989] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:0=
0/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
> > [  674.929994] CPU 7=20
> > [  674.929997] Modules linked in: autofs4 binfmt_misc ipt_MASQUERAD=
E iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_connt=
rack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp =
llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_co=
dec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_m=
ixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd=
_seq_midi_event snd_seq snd_timer snd_seq_device snd asus_atk0110 sound=
core psmouse snd_page_alloc serio_raw usbhid mvsas libsas floppy scsi_t=
ransport_sas sky2 e1000e
> > [  674.930067]=20
> > [  674.930072] Pid: 4525, comm: dnsmasq Tainted: G      D    2.6.34=
-rc6-net #121 P6T DELUXE/System Product Name
> > [  674.930077] RIP: 0010:[<ffffffff813e97c1>]  [<ffffffff813e97c1>]=
 ip_cmsg_recv+0x31/0x2d0
> > [  674.930084] RSP: 0018:ffff8801bcf03ac8  EFLAGS: 00010246
> > [  674.930088] RAX: 0000000000000000 RBX: ffff8801b746c500 RCX: 000=
0000000000000
> > [  674.930092] RDX: ffff8801bcf03e48 RSI: ffff8801b746c500 RDI: fff=
f8801bcf03f18
> > [  674.930097] RBP: ffff8801bcf03b48 R08: 0000000000000640 R09: 000=
0000000000000
> > [  674.930101] R10: 0000000000000020 R11: 0000000000000246 R12: fff=
f8801bcf03f18
> > [  674.930105] R13: ffff8801bcf03f18 R14: 0000000000000000 R15: fff=
f8801bd430850
> > [  674.930110] FS:  00007f42211eb700(0000) GS:ffff880001ee0000(0000=
) knlGS:0000000000000000
> > [  674.930114] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  674.930118] CR2: 0000000000000322 CR3: 00000001bb96b000 CR4: 000=
00000000006e0
> > [  674.930122] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [  674.930127] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [  674.930132] Process dnsmasq (pid: 4525, threadinfo ffff8801bcf02=
000, task ffff8801bd52ae40)
> > [  674.930135] Stack:
> > [  674.930137]  0000000000000134 000000000000012c ffff8801bcf03b48 =
ffffffff813b065b
> > [  674.930144] <0> ffff8801bcf03b08 ffffffff8123ce8e ffff8801bd4308=
00 ffff8801bcf03dc8
> > [  674.930152] <0> ffff8801bcf03b18 ffffffff81464612 ffff8801bcf03b=
48 0000000003fe9d95
> > [  674.930160] Call Trace:
> > [  674.930167]  [<ffffffff813b065b>] ? skb_copy_datagram_iovec+0x5b=
/0x2c0
> > [  674.930174]  [<ffffffff8123ce8e>] ? do_raw_spin_unlock+0x5e/0xb0
> > [  674.930180]  [<ffffffff81464612>] ? _raw_spin_unlock_bh+0x12/0x2=
0
> > [  674.930187]  [<ffffffff8140cf01>] udp_recvmsg+0x291/0x2b0
> > [  674.930193]  [<ffffffff8141403a>] inet_recvmsg+0x4a/0x80
> > [  674.930199]  [<ffffffff813a3d2b>] sock_recvmsg+0xeb/0x120
> > [  674.930206]  [<ffffffff814388c0>] ? unix_dgram_sendmsg+0x5b0/0x6=
30
> > [  674.930212]  [<ffffffff8123cf34>] ? do_raw_spin_lock+0x54/0x150
> > [  674.930218]  [<ffffffff813af8a3>] ? verify_iovec+0x93/0x100
> > [  674.930224]  [<ffffffff813a52bc>] __sys_recvmsg+0x14c/0x2d0
> > [  674.930231]  [<ffffffff813a56f4>] sys_recvmsg+0x44/0x80
> > [  674.930238]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b
> > [  674.930241] Code: c4 80 48 89 5d e0 4c 89 6d f0 65 48 8b 04 25 2=
8 00 00 00 48 89 45 d8 31 c0 4c 89 65 e8 4c 89 75 f8 49 89 fd 48 8b 46 =
18 48 89 f3 <44> 0f b7 a0 22 03 00 00 41 f6 c4 01 74 4b 48 8b 46 58 8b =
96 c4=20
> > [  674.930307] RIP  [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.930313]  RSP <ffff8801bcf03ac8>
> > [  674.930315] CR2: 0000000000000322
> > [  674.930319] ---[ end trace 443be32e81365555 ]---
> > [  674.930322] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000322
> > [  674.930327] IP: [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.930332] PGD 1b97f1067 PUD 1bb827067 PMD 0=20
> > [  674.930338] Oops: 0000 [#3] SMP=20
> > [  674.930341] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:0=
0/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
> > [  674.930345] CPU 3=20
> > [  674.930347] Modules linked in: autofs4 binfmt_misc ipt_MASQUERAD=
E iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_connt=
rack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp =
llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_co=
dec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_m=
ixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd=
_seq_midi_event snd_seq snd_timer snd_seq_device snd asus_atk0110 sound=
core psmouse snd_page_alloc serio_raw usbhid mvsas libsas floppy scsi_t=
ransport_sas sky2 e1000e
> > [  674.930396]=20
> > [  674.930401] Pid: 4561, comm: dnsmasq Tainted: G      D    2.6.34=
-rc6-net #121 P6T DELUXE/System Product Name
> > [  674.930405] RIP: 0010:[<ffffffff813e97c1>]  [<ffffffff813e97c1>]=
 ip_cmsg_recv+0x31/0x2d0
> > [  674.930413] RSP: 0018:ffff8801bcd95ac8  EFLAGS: 00010246
> > [  674.930417] RAX: 0000000000000000 RBX: ffff8801b746cb00 RCX: 000=
0000000000000
> > [  674.930421] RDX: ffff8801bcd95e48 RSI: ffff8801b746cb00 RDI: fff=
f8801bcd95f18
> > [  674.930425] RBP: ffff8801bcd95b48 R08: 0000000000000640 R09: 000=
0000000000000
> > [  674.930429] R10: 0000000000000020 R11: 0000000000000246 R12: fff=
f8801bcd95f18
> > [  674.930433] R13: ffff8801bcd95f18 R14: 0000000000000000 R15: fff=
f8801b6bf8c50
> > [  674.930439] FS:  00007fc947627700(0000) GS:ffff880001e60000(0000=
) knlGS:0000000000000000
> > [  674.930443] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  674.930447] CR2: 0000000000000322 CR3: 00000001b9654000 CR4: 000=
00000000006e0
> > [  674.930451] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [  674.930455] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [  674.930460] Process dnsmasq (pid: 4561, threadinfo ffff8801bcd94=
000, task ffff8801bd5b1720)
> > [  674.930464] Stack:
> > [  674.930466]  0000000000000134 000000000000012c ffff8801bcd95b48 =
ffffffff813b065b
> > [  674.930473] <0> ffff8801bcd95b08 ffffffff8123ce8e ffff8801b6bf8c=
00 ffff8801bcd95dc8
> > [  674.930481] <0> ffff8801bcd95b18 ffffffff81464612 ffff8801bcd95b=
48 000000008ae6d276
> > [  674.930490] Call Trace:
> > [  674.930496]  [<ffffffff813b065b>] ? skb_copy_datagram_iovec+0x5b=
/0x2c0
> > [  674.930503]  [<ffffffff8123ce8e>] ? do_raw_spin_unlock+0x5e/0xb0
> > [  674.930509]  [<ffffffff81464612>] ? _raw_spin_unlock_bh+0x12/0x2=
0
> > [  674.930516]  [<ffffffff8140cf01>] udp_recvmsg+0x291/0x2b0
> > [  674.930522]  [<ffffffff8141403a>] inet_recvmsg+0x4a/0x80
> > [  674.930529]  [<ffffffff813a3d2b>] sock_recvmsg+0xeb/0x120
> > [  674.930537]  [<ffffffff810704e2>] ? finish_wait+0x62/0x80
> > [  674.930543]  [<ffffffff814623f3>] ? __wait_on_bit_lock+0x73/0xb0
> > [  674.930550]  [<ffffffff81070390>] ? wake_bit_function+0x0/0x40
> > [  674.930556]  [<ffffffff813af8a3>] ? verify_iovec+0x93/0x100
> > [  674.930562]  [<ffffffff813a52bc>] __sys_recvmsg+0x14c/0x2d0
> > [  674.930569]  [<ffffffff813a56f4>] sys_recvmsg+0x44/0x80
> > [  674.930576]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b
> > [  674.930579] Code: c4 80 48 89 5d e0 4c 89 6d f0 65 48 8b 04 25 2=
8 00 00 00 48 89 45 d8 31 c0 4c 89 65 e8 4c 89 75 f8 49 89 fd 48 8b 46 =
18 48 89 f3 <44> 0f b7 a0 22 03 00 00 41 f6 c4 01 74 4b 48 8b 46 58 8b =
96 c4=20
> > [  674.930636] RIP  [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.930641]  RSP <ffff8801bcd95ac8>
> > [  674.930642] CR2: 0000000000000322
> > [  674.930645] ---[ end trace 443be32e81365556 ]---
> > [  674.930647] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000322
> > [  674.930653] IP: [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.930660] PGD 1bcdbc067 PUD 1bbc3c067 PMD 0=20
> > [  674.930666] Oops: 0000 [#4] SMP=20
> > [  674.930669] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:0=
0/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
> > [  674.930672] CPU 4=20
> > [  674.930673] Modules linked in: autofs4 binfmt_misc ipt_MASQUERAD=
E iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_connt=
rack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp =
llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_co=
dec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_m=
ixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd=
_seq_midi_event snd_seq snd_timer snd_seq_device snd asus_atk0110 sound=
core psmouse snd_page_alloc serio_raw usbhid mvsas libsas floppy scsi_t=
ransport_sas sky2 e1000e
> > [  674.930712]=20
> > [  674.930715] Pid: 4488, comm: dnsmasq Tainted: G      D    2.6.34=
-rc6-net #121 P6T DELUXE/System Product Name
> > [  674.930718] RIP: 0010:[<ffffffff813e97c1>]  [<ffffffff813e97c1>]=
 ip_cmsg_recv+0x31/0x2d0
> > [  674.930723] RSP: 0018:ffff8801bcd93ac8  EFLAGS: 00010246
> > [  674.930725] RAX: 0000000000000000 RBX: ffff8801b746cf00 RCX: 000=
0000000000000
> > [  674.930727] RDX: ffff8801bcd93e48 RSI: ffff8801b746cf00 RDI: fff=
f8801bcd93f18
> > [  674.930730] RBP: ffff8801bcd93b48 R08: 0000000000000640 R09: 000=
0000000000000
> > [  674.930732] R10: 0000000000000020 R11: 0000000000000246 R12: fff=
f8801bcd93f18
> > [  674.930735] R13: ffff8801bcd93f18 R14: 0000000000000000 R15: fff=
f8801b6bf8450
> > [  674.930738] FS:  00007f4ccbd68700(0000) GS:ffff880001e80000(0000=
) knlGS:0000000000000000
> > [  674.930741] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  674.930743] CR2: 0000000000000322 CR3: 00000001bb81d000 CR4: 000=
00000000006e0
> > [  674.930745] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [  674.930748] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [  674.930751] Process dnsmasq (pid: 4488, threadinfo ffff8801bcd92=
000, task ffff8801bde2dc80)
> > [  674.930753] Stack:
> > [  674.930754]  0000000000000134 000000000000012c ffff8801bcd93b48 =
ffffffff813b065b
> > [  674.930758] <0> ffff8801bcd93b08 ffffffff8123ce8e ffff8801b6bf84=
00 ffff8801bcd93dc8
> > [  674.930763] <0> ffff8801bcd93b18 ffffffff81464612 ffff8801bcd93b=
48 00000000d5628d65
> > [  674.930768] Call Trace:
> > [  674.930773]  [<ffffffff813b065b>] ? skb_copy_datagram_iovec+0x5b=
/0x2c0
> > [  674.930778]  [<ffffffff8123ce8e>] ? do_raw_spin_unlock+0x5e/0xb0
> > [  674.930783]  [<ffffffff81464612>] ? _raw_spin_unlock_bh+0x12/0x2=
0
> > [  674.930787]  [<ffffffff8140cf01>] udp_recvmsg+0x291/0x2b0
> > [  674.930792]  [<ffffffff8141403a>] inet_recvmsg+0x4a/0x80
> > [  674.930796]  [<ffffffff813a3d2b>] sock_recvmsg+0xeb/0x120
> > [  674.930801]  [<ffffffff814388c0>] ? unix_dgram_sendmsg+0x5b0/0x6=
30
> > [  674.930806]  [<ffffffff81119e12>] ? link_path_walk+0x502/0xaf0
> > [  674.930810]  [<ffffffff813a3728>] ? sock_aio_write+0x138/0x150
> > [  674.930815]  [<ffffffff810ca88d>] ? find_get_page+0x1d/0xc0
> > [  674.930819]  [<ffffffff813af8a3>] ? verify_iovec+0x93/0x100
> > [  674.930823]  [<ffffffff813a52bc>] __sys_recvmsg+0x14c/0x2d0
> > [  674.930828]  [<ffffffff813a56f4>] sys_recvmsg+0x44/0x80
> > [  674.930833]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b
> > [  674.930835] Code: c4 80 48 89 5d e0 4c 89 6d f0 65 48 8b 04 25 2=
8 00 00 00 48 89 45 d8 31 c0 4c 89 65 e8 4c 89 75 f8 49 89 fd 48 8b 46 =
18 48 89 f3 <44> 0f b7 a0 22 03 00 00 41 f6 c4 01 74 4b 48 8b 46 58 8b =
96 c4=20
> > [  674.930880] RIP  [<ffffffff813e97c1>] ip_cmsg_recv+0x31/0x2d0
> > [  674.930884]  RSP <ffff8801bcd93ac8>
> > [  674.930886] CR2: 0000000000000322
> > [  674.930889] ---[ end trace 443be32e81365557 ]---
>=20
> Hmm, skb->sk is NULL
>=20
> void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
> {
> 	struct inet_sock *inet =3D inet_sk(skb->sk);
> 	unsigned flags =3D inet->cmsg_flags; // CRASH
>=20
>=20
> So a skb_free_datagram_locked() is at fault here...
>=20
> commit 4b0b72f7dd617b13abd1b04c947e15873e011a24 probably
>=20
> OK, the skb_orphan() should not be done at this point, if we are not =
the
> only user (and last user)
>=20
> Oh well, sorry for the regression ;)
>=20
>=20
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 95b851f..88949b0 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -230,12 +230,8 @@ EXPORT_SYMBOL(skb_free_datagram);
>  void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
>  {
>  	lock_sock_bh(sk);
> -	skb_orphan(skb);
> -	sk_mem_reclaim_partial(sk);
> +	skb_free_datagram(sk, skb);
>  	unlock_sock_bh(sk);
> -
> -	/* skb is now orphaned, might be freed outside of locked section */
> -	consume_skb(skb);
>  }
>  EXPORT_SYMBOL(skb_free_datagram_locked);

This works great for me. No messages for several hours.

--=20
