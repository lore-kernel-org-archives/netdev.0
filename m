From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET][TG3] Fwd: page allocation failure with linux 3.1.1
Date: Mon, 28 Nov 2011 07:35:45 +0100
Message-ID: <1322462145.2826.6.camel@edumazet-laptop>
References: <CALkh-HhkzHb7-2LAwCNOZ-S4otfeM+tthyw2_XDbDUjFRSkKjA@mail.gmail.com>
	 <CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9F=D0=BB=D0=B0=D0=BC=D0=B5=D0=BD_?=
	 =?UTF-8?Q?=D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2?=
	<plamen.sisi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41032 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab1K1Gfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 01:35:50 -0500
Received: by bke11 with SMTP id 11so8067359bke.19
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2011 22:35:49 -0800 (PST)
In-Reply-To: <CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 27 novembre 2011 =C3=A0 22:34 +0200, =D0=9F=D0=BB=D0=B0=D0=BC=
=D0=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2 a =C3=A9crit :
> Hello, David, Jarek and Eric!
>=20
> In September 2010 I had trouble with the Broadcom Tygon 3 network dri=
ver:
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dco=
mmitdiff;h=3D64289c8e6851bca0e589e064c9a5c9fbd6ae5dd4
>=20
> Please, see below my most recent findings, where again tg3 is present=
=2E
>=20
> I sent this earlier today to linux-kernel list. Sorry if this is not
> related to the above, thus to the tg3 kernel driver.
>=20
> ---------- Forwarded message ----------
> From: =D0=9F=D0=BB=D0=B0=D0=BC=D0=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=
=BE=D0=B2 <plamen.sisi@gmail.com>
> Date: 2011/11/27
> Subject: page allocation failure with linux 3.1.1
> To: linux-kernel@vger.kernel.org
>=20
>=20
> Hello, folks!
>=20
> Please, cc me, as I'm not subsribed to the list.
>=20
> With Linux 3.1.1 I'm hitting a page allocation failure on a machine
> with 512 MB RAM and 2 GB swap, which looks like this:
>=20
> [388632.749423] swapper: page allocation failure: order:4, mode:0x402=
0
> [388632.749431] Pid: 0, comm: swapper Not tainted 3.1.1-FS #1
> [388632.749434] Call Trace:
> [388632.749447]  [<c106cd03>] ? warn_alloc_failed+0xab/0xd5
> [388632.749454]  [<c106f5f5>] ? __alloc_pages_nodemask+0x4ea/0x6aa
> [388632.749460]  [<c106f822>] ? __get_free_pages+0x14/0x32
> [388632.749467]  [<c12aecc7>] ? __alloc_skb+0x4c/0xe9
> [388632.749472]  [<c12b02cc>] ? skb_copy+0x2e/0x7a
> [388632.749478]  [<c122de36>] ? tg3_start_xmit+0x82f/0xa37
> [388632.749484]  [<c12b778b>] ? dev_hard_start_xmit+0x27e/0x4f8
> [388632.749495]  [<c130e851>] ? ip_fragment+0x7dd/0x7dd
> [388632.749500]  [<c12e8b88>] ? nf_iterate+0x66/0x87
> [388632.749505]  [<c12ca904>] ? sch_direct_xmit+0xa8/0x170
> [388632.749510]  [<c12e8c0f>] ? nf_hook_slow+0x66/0x11f
> [388632.749514]  [<c12b7c05>] ? dev_queue_xmit+0x129/0x4ce
> [388632.749518]  [<c130db10>] ? ip_local_out+0x18/0x1a
> [388632.749523]  [<c1321630>] ? tcp_transmit_skb+0x380/0x843
> [388632.749527]  [<c1321d5b>] ? tcp_write_xmit+0x1ba/0x956
> [388632.749532]  [<c132254e>] ? __tcp_push_pending_frames+0x24/0x7e
> [388632.749536]  [<c131f622>] ? tcp_rcv_established+0x3b2/0x74d
> [388632.749541]  [<c134831c>] ? ipv4_confirm+0xe1/0x179
> [388632.749545]  [<c1325f59>] ? tcp_v4_do_rcv+0x133/0x361
> [388632.749550]  [<c12e8b88>] ? nf_iterate+0x66/0x87
> [388632.749555]  [<c1149923>] ? security_sock_rcv_skb+0xc/0xd
> [388632.749559]  [<c13283bf>] ? tcp_v4_rcv+0x536/0x789
> [388632.749564]  [<c130a54a>] ? ip_local_deliver_finish+0x91/0x1ff
> [388632.749568]  [<c130a4b9>] ? ip_rcv_finish+0x339/0x339
> [388632.749572]  [<c130a27b>] ? ip_rcv_finish+0xfb/0x339
> [388632.749576]  [<c12b5ac6>] ? __netif_receive_skb+0xf5/0x438
> [388632.749581]  [<c12b890a>] ? netif_receive_skb+0x60/0x65
> [388632.749585]  [<c12b8bff>] ? napi_skb_finish+0x28/0x36
> [388632.749589]  [<c1232909>] ? tg3_poll_work+0x4da/0xaf0
> [388632.749594]  [<c1006760>] ? text_poke_smp_batch+0x31/0x31
> [388632.749599]  [<c1233016>] ? tg3_poll+0x5b/0x2e8
> [388632.749603]  [<c12b90af>] ? net_rx_action+0x70/0xfd
> [388632.749608]  [<c10331b1>] ? __do_softirq+0x6e/0xe7
> [388632.749612]  [<c1033143>] ? local_bh_enable_ip+0x76/0x76
> [388632.749614]  <IRQ>  [<c10333ea>] ? irq_exit+0x65/0x86
> [388632.749621]  [<c1003ca0>] ? do_IRQ+0x3a/0x97
> [388632.749627]  [<c13cc429>] ? common_interrupt+0x29/0x30
> [388632.749631]  [<c1008044>] ? mwait_idle+0x42/0x4f
> [388632.749635]  [<c100140a>] ? cpu_idle+0x50/0x78
> [388632.749640]  [<c159a627>] ? start_kernel+0x271/0x276
> [388632.749644]  [<c159a15e>] ? loglevel+0x2b/0x2b
> [388632.749646] Mem-Info:
> [388632.749648] DMA per-cpu:
> [388632.749651] CPU    0: hi:    0, btch:   1 usd:   0
> [388632.749654] CPU    1: hi:    0, btch:   1 usd:   0
> [388632.749656] Normal per-cpu:
> [388632.749659] CPU    0: hi:  186, btch:  31 usd: 138
> [388632.749662] CPU    1: hi:  186, btch:  31 usd: 127
> [388632.749667] active_anon:3930 inactive_anon:8795 isolated_anon:0
> [388632.749669]  active_file:42299 inactive_file:49253 isolated_file:=
0
> [388632.749670]  unevictable:0 dirty:518 writeback:0 unstable:0
> [388632.749672]  free:2317 slab_reclaimable:5924 slab_unreclaimable:3=
513
> [388632.749673]  mapped:3122 shmem:50 pagetables:469 bounce:0
> [388632.749681] DMA free:3056kB min:84kB low:104kB high:124kB
> active_anon:0kB inactive_anon:8kB active_file:2004kB
> inactive_file:8168kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:15804kB mlocked:0kB dirty:0kB writeback:0k=
B
> mapped:12kB shmem:0kB slab_reclaimable:1168kB slab_unreclaimable:196k=
B
> kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [388632.749687] lowmem_reserve[]: 0 490 490
> [388632.749697] Normal free:6212kB min:2788kB low:3484kB high:4180kB
> active_anon:15720kB inactive_anon:35172kB active_file:167192kB
> inactive_file:188844kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:502396kB mlocked:0kB dirty:2072kB
> writeback:0kB mapped:12476kB shmem:200kB slab_reclaimable:22528kB
> slab_unreclaimable:13856kB kernel_stack:1280kB pagetables:1876kB
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? no
> [388632.749703] lowmem_reserve[]: 0 0 0
> [388632.749708] DMA: 360*4kB 94*8kB 48*16kB 3*32kB 0*64kB 0*128kB
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 3056kB
> [388632.749721] Normal: 633*4kB 264*8kB 66*16kB 16*32kB 0*64kB 0*128k=
B
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 6212kB
> [388632.749733] 92084 total pagecache pages
> [388632.749736] 482 pages in swap cache
> [388632.749738] Swap cache stats: add 6685, delete 6203, find 168669/=
168766
> [388632.749741] Free swap  =3D 1984732kB
> [388632.749743] Total swap =3D 2007996kB
> [388632.751066] 130668 pages RAM
> [388632.751069] 2789 pages reserved
> [388632.751071] 65065 pages shared
> [388632.751073] 84385 pages non-shared
>=20
> The swap partition is on a software raid 1 device, like this:
>=20
> root@master:~# swapon -s
> Filename                                Type            Size    Used =
   Priority
> /dev/md/2                               partition       2007996 46912=
   -1
>=20
> Should I try running Linux 3.1.2 or 3.1.3 ?
>=20
> I'm attaching the full dmesg, as well as the kernel .config file used=
=2E
>=20
> Also, if anyone needs more details about my setup - just ask, and I'l=
l
> help with what I can.
>=20
> Thanks in advance,
> Plamen Petrov

You hit a known tg3 hardware bug, and the workaround needs to copy skb
to a new one.

Since TCP layer can build big skbs if TSO is on, and you can hit an
allocation error because your memory gets fragmented after a while, a
way to avoid this is to switch off TSO :

ethtool -K eth0 tso off
ip route flush cache
