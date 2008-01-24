From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Thu, 24 Jan 2008 10:42:52 +0800
Message-ID: <a8e1da0801231842m128d8261oc14135716a0a2d85@mail.gmail.com>
References: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
	 <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801221744m37021e88h5c188e5b31ea42bf@mail.gmail.com>
	 <20080122.190137.206066966.davem@davemloft.net>
	 <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
	 <Pine.LNX.4.64.0801231034300.31652@kivilampi-30.cs.helsinki.fi>
	 <Pine.LNX.4.64.0801231256360.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:51348 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbYAXCm6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 21:42:58 -0500
Received: by wx-out-0506.google.com with SMTP id h31so51891wxd.4
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 18:42:52 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0801231256360.31652@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 23, 2008 7:01 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wr=
ote:
> On Wed, 23 Jan 2008, Ilpo J=E4rvinen wrote:
>
> > On Wed, 23 Jan 2008, Dave Young wrote:
> >
> > > On Jan 23, 2008 3:41 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.=
fi> wrote:
> > > >
> > > > On Tue, 22 Jan 2008, David Miller wrote:
> > > >
> > > > > From: "Dave Young" <hidave.darkstar@gmail.com>
> > > > > Date: Wed, 23 Jan 2008 09:44:30 +0800
> > > > >
> > > > > > On Jan 22, 2008 6:47 PM, Ilpo J=E4rvinen <ilpo.jarvinen@hel=
sinki.fi> wrote:
> > > > > > > [PATCH] [TCP]: debug S+L
> > > > > >
> > > > > > Thanks, If there's new findings I will let you know.
> > > > >
> > > > > Thanks for helping with this bug Dave.
> > > >
> > > > I noticed btw that there thing might (is likely to) spuriously =
trigger at
> > > > WARN_ON(sacked !=3D tp->sacked_out); because those won't be equ=
al when SACK
> > > > is not enabled. If that does happen too often, I send a fixed p=
atch for
> > > > it, yet, the fact that I print print tp->rx_opt.sack_ok allows
> > > > identification of those cases already as it's zero when SACK is=
 not
> > > > enabled.
> > > >
> > > > Just ask if you need the updated debug patch.
> > >
> > > Thanks,  please send, I would like to get it.
> >
> > There you go. I fixed non-SACK case by adding tcp_is_sack checks th=
ere and
> > also added two verifys to tcp_ack to see if there's corruption outs=
ide of
> > TCP.
>
> There's some discussion about a problem that is very likely the same =
as in
> here (sorry for not remembering to cc you in there due to rapid progr=
ess):
>
>    http://marc.info/?t=3D120107174200003&r=3D1&w=3D2

Thanks.

New warning trigged with your debug patch:

ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1b.0 to 64
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
ACPI: PCI Interrupt 0000:03:08.0[A] -> GSI 20 (level, low) -> IRQ 20
e100: eth1: e100_probe: addr 0xefaff000, irq 20, MAC addr 00:13:72:e7:4=
d:66
eth0:  setting full-duplex.
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0150030>] ? timer_list_show_tickdevices+0xf0/0x110
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c0153251>] ? put_lock_stats+0x21/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03f7509>] ? tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c03f5540>] tcp_add_reno_sack+0x30/0x50
 [<c03f6d72>] tcp_fastretrans_alert+0x3d2/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s1 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0250030>] ? generic_make_request+0x1c0/0x2e0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f674e>] tcp_try_to_open+0x2e/0x160
 [<c03f6e9e>] tcp_fastretrans_alert+0x4fe/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s1 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fcf03>] tcp_write_xmit+0x63/0x290
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03fa23e>] tcp_rcv_established+0x40e/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s1 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132128>] ? printk+0x18/0x20
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c025f9e4>] ? vsnprintf+0x2d4/0x4f0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c03f7509>] tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c03f7dd2>] tcp_ack+0x122/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s1 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c025f9e4>] ? vsnprintf+0x2d4/0x4f0
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03f7509>] ? tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c03f6a93>] tcp_fastretrans_alert+0xf3/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s1 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0250030>] ? generic_make_request+0x1c0/0x2e0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f5540>] tcp_add_reno_sack+0x30/0x50
 [<c03f6d72>] tcp_fastretrans_alert+0x3d2/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 2 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s2 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0250030>] ? generic_make_request+0x1c0/0x2e0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f674e>] tcp_try_to_open+0x2e/0x160
 [<c03f6e9e>] tcp_fastretrans_alert+0x4fe/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 2 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s2 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fcf03>] tcp_write_xmit+0x63/0x290
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03fa23e>] tcp_rcv_established+0x40e/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f3e>] ? __do_softirq+0x6e/0x120
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 2 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s2 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132128>] ? printk+0x18/0x20
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c025f9e4>] ? vsnprintf+0x2d4/0x4f0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c03f7509>] tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c03f7dd2>] tcp_ack+0x122/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 2 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s2 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c025f9e4>] ? vsnprintf+0x2d4/0x4f0
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03f7509>] ? tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c03f6a93>] tcp_fastretrans_alert+0xf3/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 2 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s2 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0250030>] ? generic_make_request+0x1c0/0x2e0
 [<c0132128>] ? printk+0x18/0x20
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f5540>] tcp_add_reno_sack+0x30/0x50
 [<c03f6d72>] tcp_fastretrans_alert+0x3d2/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 0 vs 0 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s)      <
TCP wq(h) +++h+<
l0 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x122/0x150()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f6052>] tcp_mark_head_lost+0x122/0x150
 [<c03f60ca>] tcp_update_scoreboard+0x4a/0x190
 [<c03f6e7a>] tcp_fastretrans_alert+0x4da/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0132438>] ? vprintk+0x308/0x320
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f5ffc>] tcp_mark_head_lost+0xcc/0x150
 [<c03f60ca>] tcp_update_scoreboard+0x4a/0x190
 [<c03f6e7a>] tcp_fastretrans_alert+0x4da/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s) LLLLl<
TCP wq(h) +++h+<
l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_output.c:1977 tcp_xmit_retransmit_queue+0x388/=
0x420()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c03f5ffc>] ? tcp_mark_head_lost+0xcc/0x150
 [<c03fdf38>] tcp_xmit_retransmit_queue+0x388/0x420
 [<c03f6c27>] tcp_fastretrans_alert+0x287/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c0132438>] ? vprintk+0x308/0x320
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03f5ffc>] ? tcp_mark_head_lost+0xcc/0x150
 [<c03fdea4>] tcp_xmit_retransmit_queue+0x2f4/0x420
 [<c03f6c27>] tcp_fastretrans_alert+0x287/0x700
 [<c03f7e63>] tcp_ack+0x1b3/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s) LLLLl<
TCP wq(h) +++h+<
l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_output.c:1467 tcp_write_xmit+0x288/0x290()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0155539>] ? mark_held_locks+0x39/0x80
 [<c01880ac>] ? __slab_free+0xac/0x150
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fd128>] tcp_write_xmit+0x288/0x290
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03fa23e>] tcp_rcv_established+0x40e/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c0186af4>] ? check_bytes_and_report+0x24/0xc0
 [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
 [<c0186bf1>] ? check_pad_bytes+0x61/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fcf03>] tcp_write_xmit+0x63/0x290
 [<c03c1578>] ? kfree_skbmem+0x98/0xc0
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03fa23e>] tcp_rcv_established+0x40e/0x710
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c04021fb>] tcp_v4_rcv+0x5db/0x660
 [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
 [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03e6147>] ip_local_deliver+0xb7/0xc0
 [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
 [<c03c01d8>] ? sock_def_readable+0x48/0xa0
 [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
 [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
 [<c03e669f>] ip_rcv+0x18f/0x290
 [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
 [<c03c8da6>] netif_receive_skb+0x2b6/0x330
 [<c03c8c17>] ? netif_receive_skb+0x127/0x330
 [<c03c8ea3>] ? process_backlog+0x83/0x100
 [<c03c8eae>] process_backlog+0x8e/0x100
 [<c03c90bc>] net_rx_action+0x13c/0x230
 [<c03c8fd9>] ? net_rx_action+0x59/0x230
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c01078b1>] do_IRQ+0x41/0x80
 [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
 [<c01059ca>] common_interrupt+0x2e/0x34
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s) LLLLl<
TCP wq(h) +++h+<
l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:1767 tcp_enter_frto+0x28c/0x2a0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0156244>] ? __lock_acquire+0x1e4/0x730
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c03f58dc>] tcp_enter_frto+0x28c/0x2a0
 [<c03ff612>] tcp_retransmit_timer+0x102/0x400
 [<c043675b>] ? _spin_lock+0x4b/0x80
 [<c03ff924>] ? tcp_write_timer+0x14/0x110
 [<c03ffa03>] tcp_write_timer+0xf3/0x110
 [<c013b95b>] run_timer_softirq+0xbb/0x190
 [<c03ff910>] ? tcp_write_timer+0x0/0x110
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c011a91d>] smp_apic_timer_interrupt+0x2d/0x40
 [<c0105aab>] apic_timer_interrupt+0x33/0x38
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c03f5748>] tcp_enter_frto+0xf8/0x2a0
 [<c03ff612>] tcp_retransmit_timer+0x102/0x400
 [<c043675b>] ? _spin_lock+0x4b/0x80
 [<c03ff924>] ? tcp_write_timer+0x14/0x110
 [<c03ffa03>] tcp_write_timer+0xf3/0x110
 [<c013b95b>] run_timer_softirq+0xbb/0x190
 [<c03ff910>] ? tcp_write_timer+0x0/0x110
 [<c0136f63>] __do_softirq+0x93/0x120
 [<c013706a>] do_softirq+0x7a/0x80
 [<c0137135>] irq_exit+0x65/0x90
 [<c011a91d>] smp_apic_timer_interrupt+0x2d/0x40
 [<c0105aab>] apic_timer_interrupt+0x33/0x38
 [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
 [<c01033a0>] ? mwait_idle+0x0/0x20
 [<c01033b2>] mwait_idle+0x12/0x20
 [<c0103141>] cpu_idle+0x61/0x110
 [<c04339fd>] rest_init+0x5d/0x60
 [<c05a47fa>] start_kernel+0x1fa/0x260
 [<c05a4190>] ? unknown_bootoption+0x0/0x130
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s) LLLLl<
TCP wq(h) +++h+<
l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_output.c:1467 tcp_write_xmit+0x288/0x290()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 2987, comm: ssmtp Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0156244>] ? __lock_acquire+0x1e4/0x730
 [<c0155567>] ? mark_held_locks+0x67/0x80
 [<c03fd128>] tcp_write_xmit+0x288/0x290
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03f1130>] tcp_sendmsg+0x760/0xb40
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c03bb85c>] sock_sendmsg+0xdc/0x110
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c0156244>] ? __lock_acquire+0x1e4/0x730
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c03bb5ff>] ? sockfd_lookup_light+0x2f/0x70
 [<c03bcfe1>] sys_sendto+0xd1/0x120
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c01413f1>] ? sys_times+0x81/0xe0
 [<c03bd062>] sys_send+0x32/0x40
 [<c03bd8e6>] sys_socketcall+0x136/0x230
 [<c010501b>] ? restore_nocheck+0x12/0x15
 [<c0104fba>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 2987, comm: ssmtp Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0156244>] ? __lock_acquire+0x1e4/0x730
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c03fcf03>] tcp_write_xmit+0x63/0x290
 [<c03fd147>] __tcp_push_pending_frames+0x17/0x80
 [<c03f1130>] tcp_sendmsg+0x760/0xb40
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c03bb85c>] sock_sendmsg+0xdc/0x110
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c0156244>] ? __lock_acquire+0x1e4/0x730
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c03bb5ff>] ? sockfd_lookup_light+0x2f/0x70
 [<c03bcfe1>] sys_sendto+0xd1/0x120
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c01413f1>] ? sys_times+0x81/0xe0
 [<c03bd062>] sys_send+0x32/0x40
 [<c03bd8e6>] sys_socketcall+0x136/0x230
 [<c010501b>] ? restore_nocheck+0x12/0x15
 [<c0104fba>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
TCP wq(s) LLLLl<
TCP wq(h) +++h+<
l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2855 tcp_clean_rtx_queue+0x552/0x5b0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 2987, comm: ssmtp Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0155539>] ? mark_held_locks+0x39/0x80
 [<c01880ac>] ? __slab_free+0xac/0x150
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c01881e7>] ? kmem_cache_free+0x97/0xe0
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c03f7782>] tcp_clean_rtx_queue+0x552/0x5b0
 [<c03f7dd2>] tcp_ack+0x122/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c03f17e3>] tcp_prequeue_process+0x73/0xa0
 [<c03f1dae>] tcp_recvmsg+0x42e/0x830
 [<c03c0873>] sock_common_recvmsg+0x43/0x60
 [<c03bbacf>] sock_recvmsg+0xef/0x120
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c03bb5ff>] ? sockfd_lookup_light+0x2f/0x70
 [<c03bd0f7>] sys_recvfrom+0x87/0xf0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c013601f>] ? do_setitimer+0x1ef/0x2e0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03bd192>] sys_recv+0x32/0x40
 [<c03bd905>] sys_socketcall+0x155/0x230
 [<c010501b>] ? restore_nocheck+0x12/0x15
 [<c0104fba>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse
snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x sg
evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
Pid: 2987, comm: ssmtp Not tainted 2.6.24-rc8-mm1 #8
 [<c0132100>] ? have_callable_console+0x20/0x30
 [<c0131844>] warn_on_slowpath+0x54/0x80
 [<c01317da>] ? print_oops_end_marker+0x2a/0x30
 [<c0131849>] ? warn_on_slowpath+0x59/0x80
 [<c0186dbd>] ? check_object+0xad/0x1e0
 [<c0155539>] ? mark_held_locks+0x39/0x80
 [<c01880ac>] ? __slab_free+0xac/0x150
 [<c015561c>] ? trace_hardirqs_on+0x7c/0x130
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
 [<c01881e7>] ? kmem_cache_free+0x97/0xe0
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c03c1534>] ? kfree_skbmem+0x54/0xc0
 [<c03f7509>] tcp_clean_rtx_queue+0x2d9/0x5b0
 [<c03f7dd2>] tcp_ack+0x122/0x3a0
 [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
 [<c03f17e3>] tcp_prequeue_process+0x73/0xa0
 [<c03f1dae>] tcp_recvmsg+0x42e/0x830
 [<c03c0873>] sock_common_recvmsg+0x43/0x60
 [<c03bbacf>] sock_recvmsg+0xef/0x120
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0154982>] ? validate_chain+0x1d2/0x320
 [<c0147420>] ? autoremove_wake_function+0x0/0x50
 [<c03bb5ff>] ? sockfd_lookup_light+0x2f/0x70
 [<c03bd0f7>] sys_recvfrom+0x87/0xf0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c010af95>] ? native_sched_clock+0x85/0xe0
 [<c015323d>] ? put_lock_stats+0xd/0x30
 [<c01532c0>] ? lock_release_holdtime+0x60/0x80
 [<c013601f>] ? do_setitimer+0x1ef/0x2e0
 [<c0156b97>] ? __lock_release+0x47/0x70
 [<c03bd192>] sys_recv+0x32/0x40
 [<c03bd905>] sys_socketcall+0x155/0x230
 [<c010501b>] ? restore_nocheck+0x12/0x15
 [<c0104fba>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
---[ end trace 14b601818e6903ac ]---
P: 4 L: 4 vs 4 S: 0 vs 3 w: 2044792269-2044796616 (0)
TCP wq(s) LLLl<
TCP wq(h) ++h+<
l4 s3 f0 p4 seq: su2044792269 hs2044795029 sn2044796616
