From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 17:12:44 +0200
Message-ID: <4703B16C.2000106@fr.ibm.com>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi> <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi> <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi> <4703AE04.5090009@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:1577 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbXJCPMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 11:12:47 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l93FCj7C816078
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 15:12:45 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93FCjxG1806418
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 17:12:45 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93FCiXs001330
	for <netdev@vger.kernel.org>; Wed, 3 Oct 2007 17:12:45 +0200
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
>=20
> not a warning on 1) with your extra verbose patch.

bummer, I got this one on 1) :(

C.

WARNING: at /home/legoater/linux/net-2.6.24.git/net/ipv4/tcp_input.c:23=
25 tcp_fastretrans_alert()

Call Trace:
 <IRQ>  [<ffffffff8022ddb6>] __wake_up+0x1f/0x4c
 [<ffffffff803fd9d3>] tcp_ack+0xcee/0x18ac
 [<ffffffff80400764>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8024e8d8>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8040795b>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff804082d5>] tcp_v4_rcv+0x624/0x9b1
 [<ffffffff803ecfa3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff803ed900>] ip_rcv+0x57c/0x5c4
 [<ffffffff8045ae53>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803ce78e>] netif_receive_skb+0x2ba/0x2de
 [<ffffffff88044505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803ce958>] net_rx_action+0xb8/0x191
 [<ffffffff802385cb>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c97c>] call_softirq+0x1c/0x28
 [<ffffffff8020e672>] do_softirq+0x3b/0xb9
 [<ffffffff802386c2>] irq_exit+0x4e/0x50
 [<ffffffff8020e48e>] do_IRQ+0xbe/0xd8
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bcc6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80464e10>] __sched_text_start+0x5f0/0x62b
 [<ffffffff80464e10>] __sched_text_start+0x5f0/0x62b
 [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80464513>] rest_init+0x57/0x59
 [<ffffffff8060c82a>] start_kernel+0x2d1/0x2dd
 [<ffffffff8060c14e>] _sinittext+0x14e/0x155

WARNING: at /home/legoater/linux/net-2.6.24.git/net/ipv4/tcp_input.c:23=
25 tcp_fastretrans_alert()

Call Trace:
 <IRQ>  [<ffffffff8022ddb6>] __wake_up+0x1f/0x4c
 [<ffffffff803fd9d3>] tcp_ack+0xcee/0x18ac
 [<ffffffff80400764>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff8024e8d8>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff8040795b>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff804082d5>] tcp_v4_rcv+0x624/0x9b1
 [<ffffffff803ecfa3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff803ed900>] ip_rcv+0x57c/0x5c4
 [<ffffffff8045ae53>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803ce78e>] netif_receive_skb+0x2ba/0x2de
 [<ffffffff88044505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803ce958>] net_rx_action+0xb8/0x191
 [<ffffffff802385cb>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c97c>] call_softirq+0x1c/0x28
 [<ffffffff8020e672>] do_softirq+0x3b/0xb9
 [<ffffffff802386c2>] irq_exit+0x4e/0x50
 [<ffffffff8020e48e>] do_IRQ+0xbe/0xd8
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bcc6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80464e10>] __sched_text_start+0x5f0/0x62b
 [<ffffffff80464e10>] __sched_text_start+0x5f0/0x62b
 [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80464513>] rest_init+0x57/0x59
 [<ffffffff8060c82a>] start_kernel+0x2d1/0x2dd


