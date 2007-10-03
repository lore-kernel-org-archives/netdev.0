From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 16:59:35 +0200
Message-ID: <4703AE57.6050503@fr.ibm.com>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi> <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi> <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi> <4703AE04.5090009@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:29613 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbXJCPAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 11:00:12 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l93F0BFv129442
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 15:00:11 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93F0Bn52732046
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 16:00:11 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93ExsNe010867
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 15:59:54 +0100
In-Reply-To: <4703AE04.5090009@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cedric Le Goater wrote:
> Ilpo J=E4rvinen wrote:
>> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>>
>>> Ilpo J=E4rvinen wrote:
>>>> Ah, that's path 1) then... Since you seem to have enough time, I w=
ould say=20
>>>> that the path 1 is good as well and bugs unrelated to the fix will=
 show up=20
>>>> there too...
>>> arg. yes. sorry for the confusion.
>>>
>>>> I should have stated it explicitly that with path 2 those 3 patche=
s should=20
>>>> not be applied because the aim is not a fix but reproducal. Path 2=
 was=20
>>>> intentionally left without the potentional fix as then nice backtr=
ace=20
>>>> informs when we can stop trying (which would hopefully occurred=20
>>>> pretty soon) :-).  But lets discard that path 2...
>>> I have 2 spare nodes so i'll run both. 1) is on already without any=
 issues
>>> i'm just compiling 2)
>=20
> Below are the messages I got on 2) right after running ketchup (which=
 does=20
> a wget www.kernel.org)=20

and a second run of ketchup gave the following.

cheers,

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

TCP wq(s) --S------<
TCP wq(i)   h      <
s1 f5 (14) p6 seq: su110259658 hs110265450 sn110278722 (0)
WARNING: at /home/legoater/linux/2.6.23-rc8-mm2-tcp_fastretrans/net/ipv=
4/tcp_ipv4.c:193 tcp_verify_fackets()

Call Trace:
 <IRQ>  [<ffffffff803250aa>] vgacon_scroll+0x188/0x1dd
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
 <IRQ>  [<ffffffff803250aa>] vgacon_scroll+0x188/0x1dd
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

TCP wq(s) ---SSS-----<
TCP wq(i)      hf    <
s3 f7 (14) p7 seq: su110259658 hs110268346 sn110278722 (110269794)




C.
