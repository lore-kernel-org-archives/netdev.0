From: Cedric Le Goater <clg@fr.ibm.com>
Subject: tcp_sacktag_one() WARNING (was Re: 2.6.24-rc4-mm1)
Date: Thu, 13 Dec 2007 18:38:40 +0100
Message-ID: <47616E20.7090203@fr.ibm.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org> <47579DD9.9030909@reub.net> <20071205233504.67366c5b.akpm@linux-foundation.org> <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi> <476034B5.80106@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:15378 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762384AbXLMRio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:38:44 -0500
In-Reply-To: <476034B5.80106@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cedric Le Goater wrote:
> Ilpo J=E4rvinen wrote:
>> On Wed, 5 Dec 2007, Andrew Morton wrote:
>>
>>> On Thu, 06 Dec 2007 17:59:37 +1100 Reuben Farrelly <reuben-linuxker=
nel@reub.net> wrote:
>>>
>>>> This non fatal oops which I have just noticed may be related to th=
is change then=20
>>>> - certainly looks networking related.
>>> yep, but it isn't e1000.  It's core TCP.
>>>
>>>> WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
>>>> Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
>>> Ilpo, Reuben's kernel is talking to you ;)
>> ...Please try the patch below. Andrew, this probably fixes your prob=
lem=20
>> (the packets <=3D tp->packets_out) as well.
>=20
> nah. I got the WARNINGs again with this patch.

I got this new one on a 2.6.24-rc5-mm1. It looked similar ?=20

C.

WARNING: at /home/legoater/linux/2.6.24-rc5-mm1/net/ipv4/tcp_input.c:12=
80 tcp_sacktag_one()
Pid: 0, comm: swapper Not tainted 2.6.24-rc5-mm1 #1

Call Trace:
 <IRQ>  [<ffffffff80410e0e>] tcp_sacktag_walk+0x2bc/0x62a
 [<ffffffff80411711>] tcp_sacktag_write_queue+0x595/0xa7c
 [<ffffffff8028ce66>] kfree+0xd4/0xe0
 [<ffffffff80411e9f>] tcp_ack+0x2a7/0xfc7
 [<ffffffff80252ca1>] mark_held_locks+0x47/0x6a
 [<ffffffff80252e5c>] trace_hardirqs_on+0xfe/0x139
 [<ffffffff80415d59>] tcp_rcv_established+0x66a/0x76d
 [<ffffffff8041bd35>] tcp_v4_do_rcv+0x37/0x3aa
 [<ffffffff8041e623>] tcp_v4_rcv+0x9a9/0xa76
 [<ffffffff80401832>] ip_local_deliver_finish+0x161/0x23c
 [<ffffffff80401d47>] ip_local_deliver+0x72/0x77
 [<ffffffff8040168d>] ip_rcv_finish+0x371/0x3b5
 [<ffffffff80401ca1>] ip_rcv+0x292/0x2c6
 [<ffffffff803e2aae>] netif_receive_skb+0x267/0x340
 [<ffffffff8806eff4>] :tg3:tg3_poll+0x5d2/0x89e
 [<ffffffff803e505c>] net_rx_action+0xd5/0x1ad
 [<ffffffff8023b0b9>] __do_softirq+0x5f/0xe3
 [<ffffffff8020c8ec>] call_softirq+0x1c/0x28
 [<ffffffff8020e7b9>] do_softirq+0x39/0x9f
 [<ffffffff8023b058>] irq_exit+0x4e/0x50
 [<ffffffff8020e900>] do_IRQ+0xb7/0xd7
 [<ffffffff8020a892>] mwait_idle+0x0/0x52
 [<ffffffff8020bbe6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8024d0cb>] __atomic_notifier_call_chain+0x20/0x83
 [<ffffffff8020a8da>] mwait_idle+0x48/0x52
 [<ffffffff80209e79>] enter_idle+0x22/0x24
 [<ffffffff8020a822>] cpu_idle+0xa1/0xc5
 [<ffffffff8021e755>] start_secondary+0x3b9/0x3c5
