From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 12:46:44 +0400
Message-ID: <48EF1674.904@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:44391 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbYJJIqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 04:46:48 -0400
In-Reply-To: <20081010075640.GA5204@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 10-10-2008 07:44, Badalian Vyacheslav wrote:
>  =20
>> Hello all!
>>    =20
>
> Hello Slavon,
>
>  =20
>> Please look to if you have time:
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11718
>>
>> We have deadlocks at few PC one times in week.
>> I can test any patches to detect and fix problem.
>> Now i test 2.6.27-rc kernel at one PC.
>>    =20
>
> A similar bug was reported by Denys Fedoryshchenko but it wasn't full=
y
> diagnosed. Anyway it looks like hardware dependent. The patch below
> can sometimes help. 2.6.27 may have this fixed too (some other way).
>
>  =20
2.6.27 - get it now!


[ 6951.841662] BUG: NMI Watchdog detected LOCKUP on CPU3, ip c01fde4c,
registers:
[ 6951.841662] Modules linked in: sch_sfq sch_htb netconsole e1000
i2c_i801 e1000e i2c_core
[ 6951.841662]
[ 6951.841662] Pid: 0, comm: swapper Not tainted (2.6.27-fw #1)
[ 6951.841662] EIP: 0060:[<c01fde4c>] EFLAGS: 00000092 CPU: 3
[ 6951.841662] EIP is at __rb_rotate_right+0xc/0x70
[ 6951.841662] EAX: f70c3c68 EBX: f70c3c68 ECX: f70c3c68 EDX: c202c134
[ 6951.841662] ESI: f70c3c68 EDI: f70c3c68 EBP: c202c134 ESP: f785fc2c
[ 6951.841662]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[ 6951.841662] Process swapper (pid: 0, ti=3Df785e000 task=3Df7832940
task.ti=3Df785e000)
[ 6951.841662] Stack: f70c3c68 f70c3c68 f70c3c68 c01fdf41 f70c3c68
00000000 c202c12c c202c134
[ 6951.841662]        c013a91f f70c3c68 c202c12c c202212c c045b100
c013ae0a 00000000 c013d63d
[ 6951.841662]        9a011800 00000652 00000001 00000282 00000652
f70c3c68 00000000 00000000
[ 6951.841662] Call Trace:
[ 6951.841662]  [<c01fdf41>] rb_insert_color+0x91/0xc0
[ 6951.841662]  [<c013a91f>] enqueue_hrtimer+0x5f/0x80
[ 6951.841662]  [<c013ae0a>] hrtimer_start+0xaa/0x130
[ 6951.841662]  [<c013d63d>] getnstimeofday+0x3d/0xe0
[ 6951.841662]  [<c02de83d>] qdisc_watchdog_schedule+0x3d/0x50
[ 6951.841662]  [<f88ac343>] htb_dequeue+0x683/0x7b0 [sch_htb]
[ 6951.841662]  [<c02ce692>] dev_hard_start_xmit+0x1d2/0x2c0
[ 6951.841662]  [<c02dc87a>] __qdisc_run+0x13a/0x1d0
[ 6951.841662]  [<c02d0ed7>] dev_queue_xmit+0x227/0x4f0
[ 6951.841662]  [<c02f29ff>] ip_finish_output+0x11f/0x280
[ 6951.841662]  [<c02f00e0>] ip_forward+0x290/0x310
[ 6951.841662]  [<c02efe35>] ip_forward_finish+0x25/0x40
[ 6951.841662]  [<c02ee9a2>] ip_rcv_finish+0x122/0x360
[ 6951.841662]  [<c02c8cc6>] __alloc_skb+0x36/0x120
[ 6951.841662]  [<c02c9d02>] __netdev_alloc_skb+0x22/0x50
[ 6951.841662]  [<c02eee20>] ip_rcv+0x0/0x290
[ 6951.841662]  [<c02ce064>] netif_receive_skb+0x274/0x4d0
[ 6951.841662]  [<c0108b1a>] nommu_map_single+0x2a/0x60
[ 6951.841662]  [<f883be39>] e1000_receive_skb+0x49/0x80 [e1000e]
[ 6951.841662]  [<f883e84c>] e1000_clean_rx_irq+0x23c/0x300 [e1000e]
[ 6951.841662]  [<f883b3ad>] e1000_clean+0x1bd/0x570 [e1000e]
[ 6951.841662]  [<c02d03bc>] net_rx_action+0x13c/0x200
[ 6951.841662]  [<c0129b72>] __do_softirq+0x82/0x100
[ 6951.841662]  [<c0129c27>] do_softirq+0x37/0x40
[ 6951.841662]  [<c0106060>] do_IRQ+0x40/0x80
[ 6951.841662]  [<c01134c7>] smp_apic_timer_interrupt+0x57/0x90
[ 6951.841662]  [<c010457f>] common_interrupt+0x23/0x28
[ 6951.841662]  [<c0109aa2>] mwait_idle+0x32/0x40
[ 6951.841662]  [<c01026c8>] cpu_idle+0x48/0xe0
[ 6951.841662]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
[ 6951.841662] Code: 24 08 83 e0 03 09 d0 89 03 8b 1c 24 83 c4 0c c3 89
56 08 eb e3 8d 76 00 8d bc 27 00 00 00 00 83 ec 0c 89 1c 24 89 c3 89 7c
24 08 <89> d7 89 74 24 04 8b 50 08 8b 30 8b 4a 04 83 e6 fc 85 c9 89 48




> Jarek P.
>
> (some offsets are OK when patching 2.6.26)
> ---
>
>  net/sched/sch_htb.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 30c999c..ff9e965 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -162,6 +162,7 @@ struct htb_sched {
> =20
>  	int rate2quantum;	/* quant =3D rate / rate2quantum */
>  	psched_time_t now;	/* cached dequeue time */
> +	psched_time_t next_watchdog;
>  	struct qdisc_watchdog watchdog;
> =20
>  	/* non shaped skbs; let them go directly thru */
> @@ -920,7 +921,11 @@ static struct sk_buff *htb_dequeue(struct Qdisc =
*sch)
>  		}
>  	}
>  	sch->qstats.overlimits++;
> -	qdisc_watchdog_schedule(&q->watchdog, next_event);
> +	if (q->next_watchdog < q->now || next_event <=3D
> +	     q->next_watchdog - PSCHED_TICKS_PER_SEC / HZ) {
> +		qdisc_watchdog_schedule(&q->watchdog, next_event);
> +		q->next_watchdog =3D next_event;
> +	}
>  fin:
>  	return skb;
>  }
> @@ -973,6 +978,7 @@ static void htb_reset(struct Qdisc *sch)
>  		}
>  	}
>  	qdisc_watchdog_cancel(&q->watchdog);
> +	q->next_watchdog =3D 0;
>  	__skb_queue_purge(&q->direct_queue);
>  	sch->q.qlen =3D 0;
>  	memset(q->row, 0, sizeof(q->row));
>
>  =20

