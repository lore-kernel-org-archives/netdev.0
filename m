From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 16:58:12 +0200
Message-ID: <4703AE04.5090009@free.fr>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi> <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi> <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:58165 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761AbXJCO6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 10:58:16 -0400
In-Reply-To: <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>> Ah, that's path 1) then... Since you seem to have enough time, I wo=
uld say=20
>>> that the path 1 is good as well and bugs unrelated to the fix will =
show up=20
>>> there too...
>> arg. yes. sorry for the confusion.
>>
>>> I should have stated it explicitly that with path 2 those 3 patches=
 should=20
>>> not be applied because the aim is not a fix but reproducal. Path 2 =
was=20
>>> intentionally left without the potentional fix as then nice backtra=
ce=20
>>> informs when we can stop trying (which would hopefully occurred=20
>>> pretty soon) :-).  But lets discard that path 2...
>> I have 2 spare nodes so i'll run both. 1) is on already without any =
issues
>> i'm just compiling 2)

Below are the messages I got on 2) right after running ketchup (which d=
oes=20
a wget www.kernel.org)=20

not a warning on 1) with your extra verbose patch.

>> I usually work on -mm, so what would be interesting for me is to hav=
e what you=20
>> need in net-2.6.24 which is getting pulled in -mm by andrew. then, i=
f=20
>> you need an extra patch for verbosity, that's fine, i'll include it =
in=20
>> my usual patchset.
>=20
> Ah, I'm sorry about the subject and the extra work it caused,=20

no problem, that was a comment for the futur patchset.
=20
> it was meant for DaveM only, didn't realize at that time it would be=20
> meaningful to you as well, thus couldn't warn you back then... Testin=
g on=20
> top of mm would be (/ have been) fine as well... From my point of vie=
w=20
> both mm and net-2.6.24 are pretty much the same (I even verified that=
=20
> those patches apply fine on top of rc8-mm2 since I thought that you m=
ight=20
> want to use that one).

He, you might have solved it with 1). If not, I'm keeping the hardware =
for
you.

Cheers,

C.

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:198 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aad0>] tcp_verify_fackets+0x163/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) -S--SSS--------------------<
TCP wq(i)       hf                   <
s4 f9 (47) p9 seq: su3460595874 hs3460607374 sn3460659962 (3460608822)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:198 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aad0>] tcp_verify_fackets+0x163/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) -S---SSSSSS------------------<
TCP wq(i)           hf                 <
s7 f12 (47) p12 seq: su3460595874 hs3460611718 sn3460659962 (3460613166=
)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) --S--------<
TCP wq(i)   h        <
s1 f7 (19) p8 seq: su3633343602 hs3633352290 sn3633370354 (0)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:198 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aad0>] tcp_verify_fackets+0x163/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) ---S-S-------<
TCP wq(i)      hf      <
s2 f9 (19) p9 seq: su3633343602 hs3633355102 sn3633370354 (3633356550)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:198 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aad0>] tcp_verify_fackets+0x163/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) ----S-SSS-----<
TCP wq(i)         hf    <
s4 f11 (19) p11 seq: su3633343602 hs3633357998 sn3633370354 (3633359446=
)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aa86>] tcp_verify_fackets+0x119/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:198 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff80323bf6>] vgacon_set_cursor_size+0x39/0xd5
 [<ffffffff8041aad0>] tcp_verify_fackets+0x163/0x237
 [<ffffffff80416e57>] tcp_fragment+0x468/0x4b8
 [<ffffffff804184a5>] tcp_retransmit_skb+0xcf/0x2f4
 [<ffffffff8041878d>] tcp_xmit_retransmit_queue+0xc3/0x31e
 [<ffffffff8041220a>] tcp_fastretrans_alert+0xb36/0xb43
 [<ffffffff80412f0f>] tcp_ack+0x5d3/0x71b
 [<ffffffff80415229>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8025419a>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8041c7ff>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041d171>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff804017e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff8040214e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046fe43>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e2e1c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e2fe8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a9b7>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aaae>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80479591>] rest_init+0x55/0x57
 [<ffffffff8063681f>] start_kernel+0x2e0/0x2ec
 [<ffffffff80636134>] _sinittext+0x134/0x13b

TCP wq(s) -----S-SSSS-----<
TCP wq(i)           hf    <
s5 f12 (19) p12 seq: su3633343602 hs3633359446 sn3633370354 (3633360894=
)


