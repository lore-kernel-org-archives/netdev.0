From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Wed, 11 Aug 2010 21:59:32 -0400
Message-ID: <20100811215932.26414efe@s6510>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44073 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933028Ab0HLB7i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 21:59:38 -0400
In-Reply-To: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Aug 2010 17:48:59 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> [See https://bugzilla.redhat.com/show_bug.cgi?id=3D592398 ]
>=20
> Latest tested kernel (from koji for Fedora 13):
>=20
> 2.6.34.3-35.rc1.fc13.x86_64
>=20
> Basically occasionally, but possibly more and more often with recent
> kernels (I think .33 and .34 are worse then .32) the sky2 driver lock=
s
> up.
>=20
> During this time the nic functions like a DSL line with a 95% drop
> rate.  ie. sometimes something does get through, but mostly it's dead=
=2E
> "ip link set eth0 down && ip link set eth0 up" is enough to fix it.
>=20
> Here's the initial occurrence of this problem on the above kernel.
>=20
> Aug 11 16:21:19 nike kernel: sky2 0000:0c:00.0: eth0: rx length error=
:
> status 0x5d60100 length 2982
> Aug 11 16:21:27 nike kernel: eth0: hw csum failure.
> Aug 11 16:21:27 nike kernel: Pid: 0, comm: swapper Not tainted
> 2.6.34.3-35.rc1.fc13.x86_64 #1
> Aug 11 16:21:27 nike kernel: Call Trace:
> Aug 11 16:21:27 nike kernel: <IRQ>  [<ffffffff813a5c5b>]
> netdev_rx_csum_fault+0x3b/0x3f
> Aug 11 16:21:27 nike kernel: [<ffffffff8139f909>]
> __skb_checksum_complete_head+0x51/0x65
> Aug 11 16:21:27 nike kernel: [<ffffffff8139f92e>]
> __skb_checksum_complete+0x11/0x13
> Aug 11 16:21:27 nike kernel: [<ffffffff8140c339>] nf_ip_checksum+0xdd=
/0xe3
> Aug 11 16:21:27 nike kernel: [<ffffffff813cc791>] udp_error+0x130/0x1=
8a
> Aug 11 16:21:27 nike kernel: [<ffffffff81037b51>] ? enqueue_task+0x5f=
/0x6a
> Aug 11 16:21:27 nike kernel: [<ffffffff81037c67>] ? activate_task+0x2=
f/0x37
> Aug 11 16:21:27 nike kernel: [<ffffffff813c7d69>] nf_conntrack_in+0x1=
80/0x90e
> Aug 11 16:21:27 nike kernel: [<ffffffff8103ea37>] ? enqueue_task_fair=
+0x44/0x87
> Aug 11 16:21:27 nike kernel: [<ffffffff81037b51>] ? enqueue_task+0x5f=
/0x6a
> Aug 11 16:21:27 nike kernel: [<ffffffff8140c995>] ipv4_conntrack_in+0=
x21/0x23
> Aug 11 16:21:27 nike kernel: [<ffffffff813c4c56>] nf_iterate+0x46/0x8=
9
> Aug 11 16:21:27 nike kernel: [<ffffffff813d4790>] ? ip_rcv_finish+0x0=
/0x362
> Aug 11 16:21:27 nike kernel: [<ffffffff813c4d03>] nf_hook_slow+0x6a/0=
xcb
> Aug 11 16:21:27 nike kernel: [<ffffffff813d4790>] ? ip_rcv_finish+0x0=
/0x362
> Aug 11 16:21:27 nike kernel: [<ffffffff813d4790>] ? ip_rcv_finish+0x0=
/0x362
> Aug 11 16:21:27 nike kernel: [<ffffffff813d4e51>] NF_HOOK.clone.1+0x4=
6/0x58
> Aug 11 16:21:27 nike kernel: [<ffffffff8106e106>] ? getnstimeofday+0x=
63/0xb9
> Aug 11 16:21:27 nike kernel: [<ffffffff813d510b>] ip_rcv+0x256/0x283
> Aug 11 16:21:27 nike kernel: [<ffffffff813a53de>] netif_receive_skb+0=
x493/0x4b9
> Aug 11 16:21:27 nike kernel: [<ffffffff813a5baa>] napi_skb_finish+0x2=
9/0x40
> Aug 11 16:21:27 nike kernel: [<ffffffff813a5bf0>] napi_gro_receive+0x=
2f/0x34
> Aug 11 16:21:27 nike kernel: [<ffffffffa0160381>] sky2_poll+0x9c5/0xc=
58 [sky2]
> Aug 11 16:21:27 nike kernel: [<ffffffff813a568f>] net_rx_action+0xaf/=
0x1ca
> Aug 11 16:21:27 nike kernel: [<ffffffff81053244>] __do_softirq+0xe5/0=
x1a6
> Aug 11 16:21:27 nike kernel: [<ffffffff8109e119>] ? handle_IRQ_event+=
0x60/0x121
> Aug 11 16:21:27 nike kernel: [<ffffffff8100ab5c>] call_softirq+0x1c/0=
x30
> Aug 11 16:21:27 nike kernel: [<ffffffff8100c342>] do_softirq+0x46/0x8=
3
> Aug 11 16:21:27 nike kernel: [<ffffffff810530b5>] irq_exit+0x3b/0x7d
> Aug 11 16:21:27 nike kernel: [<ffffffff81452434>] do_IRQ+0xac/0xc3
> Aug 11 16:21:27 nike kernel: [<ffffffff8144cb93>] ret_from_intr+0x0/0=
x11
> Aug 11 16:21:27 nike kernel: <EOI>  [<ffffffff8127ef7b>] ?
> acpi_idle_enter_bm+0x288/0x2bc
> Aug 11 16:21:27 nike kernel: [<ffffffff8127ef74>] ?
> acpi_idle_enter_bm+0x281/0x2bc
> Aug 11 16:21:27 nike kernel: [<ffffffff81379458>] cpuidle_idle_call+0=
x99/0xf1
> Aug 11 16:21:27 nike kernel: [<ffffffff81008c22>] cpu_idle+0xaa/0xe4
> Aug 11 16:21:27 nike kernel: [<ffffffff8144553e>] start_secondary+0x2=
53/0x294
> Aug 11 16:21:34 nike kernel: eth0: hw csum failure.
> Aug 11 16:21:34 nike kernel: Pid: 0, comm: swapper Not tainted
> 2.6.34.3-35.rc1.fc13.x86_64 #1
> Aug 11 16:21:34 nike kernel: Call Trace:
> Aug 11 16:21:34 nike kernel: <IRQ>  [<ffffffff813a5c5b>]
> netdev_rx_csum_fault+0x3b/0x3f
> Aug 11 16:21:34 nike kernel: [<ffffffff8139f909>]
> __skb_checksum_complete_head+0x51/0x65
> Aug 11 16:21:34 nike kernel: [<ffffffff8139f92e>] __skb_checksum_comp=
lete+0x11/0
> ...
> etc, 700 messages over the course of the next hour (until I came back
> and ip link down/up fixed it).
>=20
> # cat /var/log/messages | egrep 'rx len'
> Aug 11 16:21:19 nike kernel: sky2 0000:0c:00.0: eth0: rx length error=
:
> status 0x5d60100 length 2982
>=20
> (also seen on an older kernel [ 2.6.33.5-112.fc13.x86_64 ]:
>   Jul 17 12:43:10 nike kernel: sky2 eth0: rx length error: status
> 0x5ea0100 length 3018
>   Jul 28 02:34:46 nike kernel: sky2 eth0: rx length error: status
> 0x5ea0100 length 1642
>   Jul 30 09:49:16 nike kernel: sky2 eth0: rx length error: status
> 0x5ea0100 length 3018
>   Jul 31 00:20:26 nike kernel: sky2 eth0: rx length error: status
> 0x5ea0100 length 3018
> and kernels before that, including 2.6.32.12-115.fc12.x86_64, but I
> think I might have seen the problem even further back than 2.6.32).
>=20
> # cat /var/log/messages | egrep 'eth0: hw csum failure\.$' | wc -l
> 694
>=20
> The call stacks differ, here's the most common symbols with the numbe=
r
> of times they occur
> (although this probably isn't particularly useful):
>=20
> # cat /var/log/messages | egrep ffffffff | sed -rn 's@^^Aug ..
> ..:..:.. nike kernel: @@p' | sort | uniq -c | egrep -v '^     [
> 1-9][0-9] '
>     602 <EOI>  [<ffffffff8127ef7b>] ? acpi_idle_enter_bm+0x288/0x2bc
>     630 [<ffffffff81008c22>] cpu_idle+0xaa/0xe4
>     694 [<ffffffff8100ab5c>] call_softirq+0x1c/0x30
>     693 [<ffffffff8100c342>] do_softirq+0x46/0x83
>     273 [<ffffffff81010261>] ? sched_clock+0x9/0xd
>     105 [<ffffffff8101038f>] ? native_sched_clock+0x2d/0x5f
>     254 [<ffffffff810205a8>] ? lapic_next_event+0x1d/0x21
>     190 [<ffffffff81037b51>] ? enqueue_task+0x5f/0x6a
>     285 [<ffffffff81037c67>] ? activate_task+0x2f/0x37
>     144 [<ffffffff8103ea37>] ? enqueue_task_fair+0x44/0x87
>     693 [<ffffffff810530b5>] irq_exit+0x3b/0x7d
>     694 [<ffffffff81053244>] __do_softirq+0xe5/0x1a6
>     103 [<ffffffff8106b281>] ? sched_clock_local+0x1c/0x82
>     693 [<ffffffff8106e106>] ? getnstimeofday+0x63/0xb9
>     202 [<ffffffff8107148d>] ? clockevents_program_event+0x7a/0x83
>     255 [<ffffffff810725e5>] ? tick_dev_program_event+0x3c/0xfc
>     703 [<ffffffff8109e119>] ? handle_IRQ_event+0x60/0x121
>     348 [<ffffffff810fe9af>] ? virt_to_head_page+0xe/0x2f
>     528 [<ffffffff81216662>] ? __bitmap_weight+0x40/0x8f
>     602 [<ffffffff8127ef74>] ? acpi_idle_enter_bm+0x281/0x2bc
>     629 [<ffffffff81379458>] cpuidle_idle_call+0x99/0xf1
>     115 [<ffffffff8139cffd>] ? __kfree_skb+0x7d/0x81
>     694 [<ffffffff8139f909>] __skb_checksum_complete_head+0x51/0x65
>     694 [<ffffffff8139f92e>] __skb_checksum_complete+0x11/0x13
>     694 [<ffffffff813a53de>] netif_receive_skb+0x493/0x4b9
>     694 [<ffffffff813a568f>] net_rx_action+0xaf/0x1ca
>     694 [<ffffffff813a5baa>] napi_skb_finish+0x29/0x40
>     694 [<ffffffff813a5bf0>] napi_gro_receive+0x2f/0x34
>     695 [<ffffffff813c4c56>] nf_iterate+0x46/0x89
>     695 [<ffffffff813c4d03>] nf_hook_slow+0x6a/0xcb
>     145 [<ffffffff813c4d20>] ? nf_hook_slow+0x87/0xcb
>     694 [<ffffffff813c7d69>] nf_conntrack_in+0x180/0x90e
>     690 [<ffffffff813cc791>] udp_error+0x130/0x18a
>    2083 [<ffffffff813d4790>] ? ip_rcv_finish+0x0/0x362
>     163 [<ffffffff813d4c58>] ? ip_local_deliver_finish+0x0/0x1b3
>     694 [<ffffffff813d4e51>] NF_HOOK.clone.1+0x46/0x58
>     694 [<ffffffff813d510b>] ip_rcv+0x256/0x283
>     694 [<ffffffff8140c339>] nf_ip_checksum+0xdd/0xe3
>     694 [<ffffffff8140c995>] ipv4_conntrack_in+0x21/0x23
>     338 [<ffffffff81434d5a>] rest_init+0x7e/0x80
>     295 [<ffffffff8144553e>] start_secondary+0x253/0x294
>     151 [<ffffffff8144c8a6>] ? _raw_spin_unlock_bh+0x15/0x17
>     687 [<ffffffff8144cb93>] ret_from_intr+0x0/0x11
>     687 [<ffffffff81452434>] do_IRQ+0xac/0xc3
>     338 [<ffffffff81bae2c8>] x86_64_start_reservations+0xb3/0xb7
>     338 [<ffffffff81bae3c4>] x86_64_start_kernel+0xf8/0x107
>     338 [<ffffffff81baee6f>] start_kernel+0x413/0x41e
>     694 [<ffffffffa0160381>] sky2_poll+0x9c5/0xc58 [sky2]
>     150 [<ffffffffa05850ea>] ? nf_nat_cleanup_conntrack+0x69/0x6d [nf=
_nat]
>     694 <IRQ>  [<ffffffff813a5c5b>] netdev_rx_csum_fault+0x3b/0x3f

What is the dmesg and lspci info. Looks like a timing issue which
is unique to your machine/bus hardware combination.  could
you just turn off hardware rx checksum (with ethtool).

