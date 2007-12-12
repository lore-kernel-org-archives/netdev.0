From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: 2.6.24-rc4-mm1
Date: Wed, 12 Dec 2007 18:57:53 +0100
Message-ID: <47602121.9080206@fr.ibm.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org> <47579DD9.9030909@reub.net> <20071205.230925.99250129.davem@davemloft.net> <Pine.LNX.4.64.0712061146120.28055@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: reuben-linuxkernel@reub.net, akpm@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, auke-jan.h.kok@intel.com,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:18458 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbXLLR57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 12:57:59 -0500
In-Reply-To: <Pine.LNX.4.64.0712061146120.28055@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 5 Dec 2007, David Miller wrote:
>=20
>> From: Reuben Farrelly <reuben-linuxkernel@reub.net>
>> Date: Thu, 06 Dec 2007 17:59:37 +1100
>>
>>> On 5/12/2007 4:17 PM, Andrew Morton wrote:
>>>> - Lots of device IDs have been removed from the e1000 driver and m=
oved over
>>>>   to e1000e.  So if your e1000 stops working, you forgot to set CO=
NFIG_E1000E.
>>> This non fatal oops which I have just noticed may be related to thi=
s change then=20
>>> - certainly looks networking related.
>>>
>>> WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
>>> Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
>>>
>>> Call Trace:
>>>   <IRQ>  [<ffffffff8046e038>] tcp_fastretrans_alert+0x229/0xe63
>>>   [<ffffffff80470975>] tcp_ack+0xa3f/0x127d
>>>   [<ffffffff804747b7>] tcp_rcv_established+0x55f/0x7f8
>>>   [<ffffffff8047b1aa>] tcp_v4_do_rcv+0xdb/0x3a7
>>>   [<ffffffff881148a8>] :nf_conntrack:nf_ct_deliver_cached_events+0x=
75/0x99
>> No, it's from TCP assertions and changes added by Ilpo to the
>> net-2.6.25 tree recently.
>=20
> Yeah, this (very likely) due to the new SACK processing (in net-2.6.2=
5).=20
> I'll look what could go wrong with fack_count calculations, most like=
ly=20
> it's the reason (I've found earlier one out-of-place retransmission=20
> segment in one of my test case which already indicated that there's=20
> something incorrect with them but didn't have time to debug it yet).
>=20
> Thanks for report. Some info about how easily you can reproduce &=20
> couple of sentences about the test case might be useful later on when=
=20
> evaluating the fix.

I also got plenty of these when untaring a tarball on NFS.

C.=20

WARNING: at /home/legoater/linux/2.6.24-rc4-mm1/net/ipv4/tcp_input.c:25=
18 tcp_fastretrans_alert()
Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #2

Call Trace:
 <IRQ>  [<ffffffff804115bf>] tcp_fastretrans_alert+0xb6/0xbf2
 [<ffffffff80413f30>] tcp_ack+0xdf3/0xfbe
 [<ffffffff803da8fb>] sk_reset_timer+0x17/0x23
 [<ffffffff80416d1e>] tcp_rcv_established+0xf3/0x76d
 [<ffffffff8041d231>] tcp_v4_do_rcv+0x37/0x3aa
 [<ffffffff8041fb1f>] tcp_v4_rcv+0x9a9/0xa76
 [<ffffffff80402e4e>] ip_local_deliver_finish+0x161/0x23c
 [<ffffffff80403363>] ip_local_deliver+0x72/0x77
 [<ffffffff80402ca9>] ip_rcv_finish+0x371/0x3b5
 [<ffffffff804032bd>] ip_rcv+0x292/0x2c6
 [<ffffffff803e3dcc>] netif_receive_skb+0x267/0x340
 [<ffffffff8806eff4>] :tg3:tg3_poll+0x5d2/0x89e
 [<ffffffff803e639d>] net_rx_action+0xd5/0x1ad
 [<ffffffff8023b605>] __do_softirq+0x5f/0xe3
 [<ffffffff8020c86c>] call_softirq+0x1c/0x28
 [<ffffffff8020e739>] do_softirq+0x39/0x9f
 [<ffffffff8023b5a4>] irq_exit+0x4e/0x50
 [<ffffffff8020e880>] do_IRQ+0xb7/0xd7
 [<ffffffff8020a803>] mwait_idle+0x0/0x55
 [<ffffffff8020bb66>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8024d623>] __atomic_notifier_call_chain+0x20/0x83
 [<ffffffff8020a84b>] mwait_idle+0x48/0x55
 [<ffffffff80209e79>] enter_idle+0x22/0x24
 [<ffffffff8020a793>] cpu_idle+0xa1/0xc5
 [<ffffffff8021dfd5>] start_secondary+0x3b9/0x3c5

WARNING: at /home/legoater/linux/2.6.24-rc4-mm1/net/ipv4/tcp_input.c:25=
18 tcp_fastretrans_alert()
Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #2

Call Trace:
 <IRQ>  [<ffffffff804115bf>] tcp_fastretrans_alert+0xb6/0xbf2
 [<ffffffff80413f30>] tcp_ack+0xdf3/0xfbe
 [<ffffffff804153b8>] tcp_data_queue+0x5da/0xb0a
 [<ffffffff80416d1e>] tcp_rcv_established+0xf3/0x76d
 [<ffffffff8041d231>] tcp_v4_do_rcv+0x37/0x3aa
 [<ffffffff8041fb1f>] tcp_v4_rcv+0x9a9/0xa76
 [<ffffffff80402e4e>] ip_local_deliver_finish+0x161/0x23c
 [<ffffffff80403363>] ip_local_deliver+0x72/0x77
 [<ffffffff80402ca9>] ip_rcv_finish+0x371/0x3b5
 [<ffffffff804032bd>] ip_rcv+0x292/0x2c6
 [<ffffffff803e3dcc>] netif_receive_skb+0x267/0x340
 [<ffffffff8806eff4>] :tg3:tg3_poll+0x5d2/0x89e
 [<ffffffff803e639d>] net_rx_action+0xd5/0x1ad
 [<ffffffff8023b605>] __do_softirq+0x5f/0xe3
 [<ffffffff8020c86c>] call_softirq+0x1c/0x28
 [<ffffffff8020e739>] do_softirq+0x39/0x9f
 [<ffffffff8023b5a4>] irq_exit+0x4e/0x50
 [<ffffffff8020e880>] do_IRQ+0xb7/0xd7
 [<ffffffff8020a803>] mwait_idle+0x0/0x55
 [<ffffffff8020bb66>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8024d623>] __atomic_notifier_call_chain+0x20/0x83
 [<ffffffff8020a84b>] mwait_idle+0x48/0x55
 [<ffffffff80209e79>] enter_idle+0x22/0x24
 [<ffffffff8020a793>] cpu_idle+0xa1/0xc5
 [<ffffffff8021dfd5>] start_secondary+0x3b9/0x3c5

WARNING: at /home/legoater/linux/2.6.24-rc4-mm1/net/ipv4/tcp_input.c:25=
18 tcp_fastretrans_alert()
Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #2

Call Trace:
 <IRQ>  [<ffffffff804115bf>] tcp_fastretrans_alert+0xb6/0xbf2
 [<ffffffff80413f30>] tcp_ack+0xdf3/0xfbe
 [<ffffffff804153b8>] tcp_data_queue+0x5da/0xb0a
 [<ffffffff80416d1e>] tcp_rcv_established+0xf3/0x76d
 [<ffffffff8041d231>] tcp_v4_do_rcv+0x37/0x3aa
 [<ffffffff8041fb1f>] tcp_v4_rcv+0x9a9/0xa76
 [<ffffffff80402e4e>] ip_local_deliver_finish+0x161/0x23c
 [<ffffffff80403363>] ip_local_deliver+0x72/0x77
 [<ffffffff80402ca9>] ip_rcv_finish+0x371/0x3b5
 [<ffffffff804032bd>] ip_rcv+0x292/0x2c6
 [<ffffffff803e3dcc>] netif_receive_skb+0x267/0x340
 [<ffffffff8806eff4>] :tg3:tg3_poll+0x5d2/0x89e
 [<ffffffff803e639d>] net_rx_action+0xd5/0x1ad
 [<ffffffff8023b605>] __do_softirq+0x5f/0xe3
 [<ffffffff8020c86c>] call_softirq+0x1c/0x28
 [<ffffffff8020e739>] do_softirq+0x39/0x9f
 [<ffffffff8023b5a4>] irq_exit+0x4e/0x50
 [<ffffffff8020e880>] do_IRQ+0xb7/0xd7
 [<ffffffff8020a803>] mwait_idle+0x0/0x55
 [<ffffffff8020bb66>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff8024d623>] __atomic_notifier_call_chain+0x20/0x83
 [<ffffffff8020a84b>] mwait_idle+0x48/0x55
 [<ffffffff80209e79>] enter_idle+0x22/0x24
 [<ffffffff8020a793>] cpu_idle+0xa1/0xc5
 [<ffffffff8021dfd5>] start_secondary+0x3b9/0x3c5

