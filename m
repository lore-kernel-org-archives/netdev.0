From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Mon, 23 May 2011 14:32:18 +0200
Message-ID: <1306153938.20687.2.camel@edumazet-laptop>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34888 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab1EWMcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 08:32:22 -0400
Received: by wwa36 with SMTP id 36so6145185wwa.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 05:32:21 -0700 (PDT)
In-Reply-To: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 mai 2011 =C3=A0 13:01 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :
> It is not  mine, just helping to forward information to netdev.
>  Arch Linux, x86_64, NAS for PPTP (with PPTP "acceleration" enabled)
>  If any other info required, please let me know.
>=20
>  Here is panic message
>=20
>  [ 4461.966303] BUG: unable to handle kernel NULL pointer dereference=
 at=20
>           (null)
>  [ 4461.969603] IP: [<ffffffffa019fb90>] sfq_enqueue+0xe0/0x630=20
>  [sch_sfq]
>  [ 4461.969603] PGD 1179a0067 PUD 1160fa067 PMD 0
>  [ 4461.969603] Oops: 0002 [#1] PREEMPT SMP
>  [ 4461.969603] last sysfs file: /sys/devices/virtual/net/ppp41/ueven=
t
>  [ 4461.969603] CPU 0
>  [ 4461.969603] Modules linked in: act_police sch_ingress cls_u32=20
>  sch_sfq sch_htb xt_TCPMSS xt_tcpudp iptable_filter ip_tables x_table=
s=20
>  igb l2tp_ppp l2tp_netlink l2tp_core pptp pppox ppp_generic slhc gre=20
>  bonding i2c_i801 firewire_ohci psmouse uhci_hcd iTCO_wdt button evde=
v=20
>  firewire_core processor intel_agp intel_gtt i2c_core asus_atk0110 dc=
a=20
>  iTCO_vendor_support ehci_hcd pcspkr serio_raw sg usbcore crc_itu_t i=
pv6=20
>  ext2 mbcache sd_mod ahci libahci pata_jmicron pata_acpi libata scsi_=
mod
>  [ 4461.969603]
>  [ 4461.969603] Pid: 0, comm: swapper Not tainted 2.6.39-ARCH #1 Syst=
em=20
>  manufacturer System Product Name/P5QD TURBO
>  [ 4461.969603] RIP: 0010:[<ffffffffa019fb90>]  [<ffffffffa019fb90>]=20
>  sfq_enqueue+0xe0/0x630 [sch_sfq]
>  [ 4461.969603] RSP: 0018:ffff88011fc03940  EFLAGS: 00010206
>  [ 4461.969603] RAX: ffff8801172a7d08 RBX: ffff8801172a7000 RCX:=20
>  ffff8801172a7100
>  [ 4461.969603] RDX: 000000000000007b RSI: 0000000000000000 RDI:=20
>  ffff8801172a7d08
>  [ 4461.969603] RBP: ffff88011fc03980 R08: ffff8801170e8ac0 R09:=20
>  0000000000000007
>  [ 4461.969603] R10: 0000000000000001 R11: ffffc900110a1000 R12:=20
>  ffff8801172a7d08
>  [ 4461.969603] R13: 0000000017cc394b R14: 00000000a54672c3 R15:=20
>  ffff880117f8109c
>  [ 4461.969603] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000)=
=20
>  knlGS:0000000000000000
>  [ 4461.969603] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>  [ 4461.969603] CR2: 0000000000000000 CR3: 00000001171b2000 CR4:=20
>  00000000000406f0
>  [ 4461.969603] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
>  0000000000000000
>  [ 4461.969603] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
>  0000000000000400
>  [ 4461.969603] Process swapper (pid: 0, threadinfo ffffffff81600000,=
=20
>  task ffffffff8169b020)
>  [ 4461.969603] Stack:
>  [ 4461.969603]  ffff88011fc039a0 ffff880117787d80 ffff88011fc03980=20
>  ffff880117f81000
>  [ 4461.969603]  ffff880117b0f400 ffff8801172a7d08 ffff8801172a7000=20
>  ffff880117f8109c
>  [ 4461.969603]  ffff88011fc039d0 ffffffffa0165080 ffff880114016f00=20
>  ffff880114016f00
>  [ 4461.969603] Call Trace:
>  [ 4461.969603]  <IRQ>
>  [ 4461.969603]  [<ffffffffa0165080>] htb_enqueue+0xb0/0x3c0 [sch_htb=
]
>  [ 4461.969603]  [<ffffffff8112f0d3>] ?=20
>  __kmalloc_node_track_caller+0x33/0x240
>  [ 4461.969603]  [<ffffffff813127b3>] dev_queue_xmit+0x1d3/0x680
>  [ 4461.969603]  [<ffffffff81345300>] ? ip_fragment+0x1d0/0x960
>  [ 4461.969603]  [<ffffffff81344252>] ip_finish_output2+0x1e2/0x2c0
>  [ 4461.969603]  [<ffffffff8134534e>] ip_fragment+0x21e/0x960
>  [ 4461.969603]  [<ffffffff81344070>] ? ip_send_check+0x50/0x50
>  [ 4461.969603]  [<ffffffff81345d8f>] ip_finish_output+0x27f/0x360
>  [ 4461.969603]  [<ffffffff81342840>] ? ip_frag_mem+0x10/0x10
>  [ 4461.969603]  [<ffffffff81346928>] ip_output+0xc8/0xe0
>  [ 4461.969603]  [<ffffffff8134287f>] ip_forward_finish+0x3f/0x50
>  [ 4461.969603]  [<ffffffff81342b25>] ip_forward+0x295/0x430
>  [ 4461.969603]  [<ffffffff81340d61>] ip_rcv_finish+0x131/0x370
>  [ 4461.969603]  [<ffffffff81303a1a>] ? __alloc_skb+0x4a/0x230
>  [ 4461.969603]  [<ffffffff8134163e>] ip_rcv+0x21e/0x2f0
>  [ 4461.969603]  [<ffffffff8130f80a>] __netif_receive_skb+0x30a/0x6c0
>  [ 4461.969603]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
>  [ 4461.969603]  [<ffffffff813103bd>] netif_receive_skb+0xad/0xc0
>  [ 4461.969603]  [<ffffffff8121867c>] ? is_swiotlb_buffer+0x3c/0x50
>  [ 4461.969603]  [<ffffffff81310d08>] napi_skb_finish+0x48/0x60
>  [ 4461.969603]  [<ffffffff81310dcd>] napi_gro_receive+0xad/0xc0
>  [ 4461.969603]  [<ffffffffa01b79b7>] igb_poll+0x8c7/0xd60 [igb]
>  [ 4461.969603]  [<ffffffff81310699>] net_rx_action+0x149/0x300
>  [ 4461.969603]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
>  [ 4461.969603]  [<ffffffff8105ea78>] __do_softirq+0xa8/0x280
>  [ 4461.969603]  [<ffffffff81089538>] ?=20
>  tick_dev_program_event+0x48/0x110
>  [ 4461.969603]  [<ffffffff8108961a>] ? tick_program_event+0x1a/0x20
>  [ 4461.969603]  [<ffffffff813cc51c>] call_softirq+0x1c/0x30
>  [ 4461.969603]  [<ffffffff8100caf5>] do_softirq+0x65/0xa0
>  [ 4461.969603]  [<ffffffff8105ef86>] irq_exit+0x96/0xb0
>  [ 4461.969603]  [<ffffffff8102784b>] smp_apic_timer_interrupt+0x6b/0=
xa0
>  [ 4461.969603]  [<ffffffff813cbcd3>] apic_timer_interrupt+0x13/0x20
>  [ 4461.969603]  <EOI>
>  [ 4461.969603]  [<ffffffff81012beb>] ? mwait_idle+0x9b/0x2d0
>  [ 4461.969603]  [<ffffffff81009226>] cpu_idle+0xb6/0x100
>  [ 4461.969603]  [<ffffffff813a903d>] rest_init+0x91/0xa4
>  [ 4461.969603]  [<ffffffff81722c32>] start_kernel+0x3ed/0x3fa
>  [ 4461.969603]  [<ffffffff81722347>]=20
>  x86_64_start_reservations+0x132/0x136
>  [ 4461.969603]  [<ffffffff81722140>] ? early_idt_handlers+0x140/0x14=
0
>  [ 4461.969603]  [<ffffffff8172244d>] x86_64_start_kernel+0x102/0x111
>  [ 4461.969603] Code: b6 70 10 3b b3 08 01 00 00 0f 8d df 01 00 00 41=
 8b=20
>  74 24 28 01 b3 b4 00 00 00 48 8b 70 08 49 89 04 24 49 89 74 24 08 48=
 8b=20
>  70 08 <4c> 89 26 0f b6 f2 4c 89 60 08 48 8d 3c 76 48 8d bc fb 90 01 =
00
>  [ 4461.969603] RIP  [<ffffffffa019fb90>] sfq_enqueue+0xe0/0x630=20
>  [sch_sfq]
>  [ 4461.969603]  RSP <ffff88011fc03940>
>  [ 4461.969603] CR2: 0000000000000000
>  [ 4463.351117] ---[ end trace f04e6b6edad2d731 ]---
>  [ 4463.364930] Kernel panic - not syncing: Fatal exception in interr=
upt
>  [ 4463.383963] Pid: 0, comm: swapper Tainted: G      D     2.6.39-AR=
CH=20
>  #1
>  [ 4463.403515] Call Trace:
>  [ 4463.410847]  <IRQ>  [<ffffffff813c16b9>] panic+0x9b/0x1a8
>  [ 4463.427073]  [<ffffffff8100e322>] oops_end+0xe2/0xf0
>  [ 4463.441944]  [<ffffffff813c117f>] no_context+0x204/0x213
>  [ 4463.457857]  [<ffffffff81346928>] ? ip_output+0xc8/0xe0
>  [ 4463.473509]  [<ffffffff813c1317>] __bad_area_nosemaphore+0x189/0x=
1ac
>  [ 4463.492542]  [<ffffffffa01b4c4b>] ?=20
>  igb_xmit_frame_ring_adv+0x1fb/0xc30 [igb]
>  [ 4463.513913]  [<ffffffff813c1348>] bad_area_nosemaphore+0xe/0x10
>  [ 4463.531645]  [<ffffffff81036329>] do_page_fault+0x3c9/0x4b0
>  [ 4463.548337]  [<ffffffff812068e4>] ? timerqueue_add+0x74/0xc0
>  [ 4463.565291]  [<ffffffff8107c4d3>] ? enqueue_hrtimer+0x33/0xe0
>  [ 4463.582503]  [<ffffffff8107d0fe>] ?=20
>  __hrtimer_start_range_ns+0x1be/0x520
>  [ 4463.602576]  [<ffffffff810b95fd>] ? handle_edge_irq+0x7d/0x120
>  [ 4463.620048]  [<ffffffff813cae85>] page_fault+0x25/0x30
>  [ 4463.635438]  [<ffffffffa019fb90>] ? sfq_enqueue+0xe0/0x630 [sch_s=
fq]
>  [ 4463.654471]  [<ffffffffa0165080>] htb_enqueue+0xb0/0x3c0 [sch_htb=
]
>  [ 4463.672983]  [<ffffffff8112f0d3>] ?=20
>  __kmalloc_node_track_caller+0x33/0x240
>  [ 4463.693576]  [<ffffffff813127b3>] dev_queue_xmit+0x1d3/0x680
>  [ 4463.710528]  [<ffffffff81345300>] ? ip_fragment+0x1d0/0x960
>  [ 4463.727221]  [<ffffffff81344252>] ip_finish_output2+0x1e2/0x2c0
>  [ 4463.744953]  [<ffffffff8134534e>] ip_fragment+0x21e/0x960
>  [ 4463.761124]  [<ffffffff81344070>] ? ip_send_check+0x50/0x50
>  [ 4463.777817]  [<ffffffff81345d8f>] ip_finish_output+0x27f/0x360
>  [ 4463.795289]  [<ffffffff81342840>] ? ip_frag_mem+0x10/0x10
>  [ 4463.811462]  [<ffffffff81346928>] ip_output+0xc8/0xe0
>  [ 4463.826592]  [<ffffffff8134287f>] ip_forward_finish+0x3f/0x50
>  [ 4463.843806]  [<ffffffff81342b25>] ip_forward+0x295/0x430
>  [ 4463.859719]  [<ffffffff81340d61>] ip_rcv_finish+0x131/0x370
>  [ 4463.876411]  [<ffffffff81303a1a>] ? __alloc_skb+0x4a/0x230
>  [ 4463.892842]  [<ffffffff8134163e>] ip_rcv+0x21e/0x2f0
>  [ 4463.907714]  [<ffffffff8130f80a>] __netif_receive_skb+0x30a/0x6c0
>  [ 4463.925966]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
>  [ 4463.941099]  [<ffffffff813103bd>] netif_receive_skb+0xad/0xc0
>  [ 4463.958310]  [<ffffffff8121867c>] ? is_swiotlb_buffer+0x3c/0x50
>  [ 4463.976044]  [<ffffffff81310d08>] napi_skb_finish+0x48/0x60
>  [ 4463.992735]  [<ffffffff81310dcd>] napi_gro_receive+0xad/0xc0
>  [ 4464.009688]  [<ffffffffa01b79b7>] igb_poll+0x8c7/0xd60 [igb]
>  [ 4464.026639]  [<ffffffff81310699>] net_rx_action+0x149/0x300
>  [ 4464.043333]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
>  [ 4464.058465]  [<ffffffff8105ea78>] __do_softirq+0xa8/0x280
>  [ 4464.074636]  [<ffffffff81089538>] ?=20
>  tick_dev_program_event+0x48/0x110
>  [ 4464.093928]  [<ffffffff8108961a>] ? tick_program_event+0x1a/0x20
>  [ 4464.111920]  [<ffffffff813cc51c>] call_softirq+0x1c/0x30
>  [ 4464.127833]  [<ffffffff8100caf5>] do_softirq+0x65/0xa0
>  [ 4464.143225]  [<ffffffff8105ef86>] irq_exit+0x96/0xb0
>  [ 4464.158098]  [<ffffffff8102784b>] smp_apic_timer_interrupt+0x6b/0=
xa0
>  [ 4464.177130]  [<ffffffff813cbcd3>] apic_timer_interrupt+0x13/0x20
>  [ 4464.195120]  <EOI>  [<ffffffff81012beb>] ? mwait_idle+0x9b/0x2d0
>  [ 4464.213145]  [<ffffffff81009226>] cpu_idle+0xb6/0x100
>  [ 4464.228274]  [<ffffffff813a903d>] rest_init+0x91/0xa4
>  [ 4464.243404]  [<ffffffff81722c32>] start_kernel+0x3ed/0x3fa
>  [ 4464.259837]  [<ffffffff81722347>]=20
>  x86_64_start_reservations+0x132/0x136
>  [ 4464.279649]  [<ffffffff81722140>] ? early_idt_handlers+0x140/0x14=
0
>  [ 4464.298161]  [<ffffffff8172244d>] x86_64_start_kernel+0x102/0x111
>=20
> =20

Ouch, thats an ip_fragment() bug I am afraid... nothing to do with SFQ

It calls=20

err =3D output(skb);

and a bit later does :

skb =3D frag;
frag =3D skb->next;   // thats completely illegal here !
skb->next =3D NULL;

I am cooking a patch and send it in a couple of minutes.

Thanks !



