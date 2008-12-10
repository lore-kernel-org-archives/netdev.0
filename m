From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Wed, 10 Dec 2008 18:14:28 +0300
Message-ID: <493FDCD4.5020108@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local> <48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:40177 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbYLJPWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 10:22:19 -0500
In-Reply-To: <20081022070200.GB4178@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again! Sorry for long away.
I was go away from this work for long time.

May we return to this bug?
Servers at last stable kernel 2.6.27.8
HZ=1000, HR=off, DynamicTicks=off, hysteresis=1
Sorry - no patched, update do not i. Do you have fresh patches or ideas
for tests?
Also debug "Debug object operations" and "Debug timer objects" is on but
i not see additional information at dump.

Thanks!

That dump:
[ 1500.932813] BUG: NMI Watchdog detected LOCKUP on CPU3, ip c0208ed9,
registers:
[ 1500.932813] Modules linked in: cls_u32 sch_sfq sch_htb netconsole
e1000e e1000 i2c_i801
[ 1500.932813]
[ 1500.932813] Pid: 0, comm: swapper Not tainted (2.6.27-gentoo-r5-fw #1)
[ 1500.932813] EIP: 0060:[<c0208ed9>] EFLAGS: 00000082 CPU: 3
[ 1500.932813] EIP is at rb_insert_color+0x29/0xf0
[ 1500.932813] EAX: f3391c68 EBX: f3391c68 ECX: 00000000 EDX: f3391c68
[ 1500.932813] ESI: 00000000 EDI: f3391c68 EBP: f3391c68 ESP: f785fc1c
[ 1500.932813]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[ 1500.932813] Process swapper (pid: 0, ti=f785e000 task=f7832940
task.ti=f785e000)
[ 1500.932813] Stack: c202c134 f3391c68 f3391c6c 00000000 c202c134
c013d5a2 c202c12c f3391c68
[ 1500.932813]        c202c12c c202212c c0480100 c013dba9 00000000
002dcd3c 76886800 0000015d
[ 1500.932813]        00000001 00000282 0000015d f3391c68 f3391800
f3391880 c02ff53d 00000000
[ 1500.932813] Call Trace:
[ 1500.932813]  [<c013d5a2>] enqueue_hrtimer+0x72/0x90
[ 1500.932813]  [<c013dba9>] hrtimer_start+0x99/0x150
[ 1500.932813]  [<c02ff53d>] qdisc_watchdog_schedule+0x3d/0x50
[ 1500.932813]  [<f88a379a>] htb_dequeue+0x6aa/0x7d0 [sch_htb]
[ 1500.932813]  [<c02ee6a2>] dev_hard_start_xmit+0x242/0x2d0
[ 1500.932813]  [<c02fccfc>] __qdisc_run+0x13c/0x1e0
[ 1500.932813]  [<c02eea81>] dev_queue_xmit+0x241/0x570
[ 1500.932813]  [<c03133a4>] ip_finish_output+0x184/0x260
[ 1500.932813]  [<c030f6a6>] ip_forward_finish+0x26/0x40
[ 1500.932813]  [<c030e1a6>] ip_rcv_finish+0x156/0x340
[ 1500.932813]  [<c02e93e2>] __netdev_alloc_skb+0x22/0x50
[ 1500.932813]  [<c02e8934>] __alloc_skb+0x34/0x120
[ 1500.932813]  [<c02e93e2>] __netdev_alloc_skb+0x22/0x50
[ 1500.932813]  [<c02edef7>] netif_receive_skb+0x227/0x4c0
[ 1500.932813]  [<f8866db6>] e1000_receive_skb+0x46/0x80 [e1000e]
[ 1500.932813]  [<f8867030>] e1000_clean_rx_irq+0x240/0x340 [e1000e]
[ 1500.932813]  [<f8865277>] e1000_clean+0x1f7/0x5b0 [e1000e]
[ 1500.932813]  [<c0121daa>] run_rebalance_domains+0x8a/0x520
[ 1500.932813]  [<c011d6b7>] __dequeue_entity+0x57/0xc0
[ 1500.932813]  [<c02ec69c>] net_rx_action+0xcc/0x1e0
[ 1500.932813]  [<c012b842>] __do_softirq+0x82/0xf0
[ 1500.932813]  [<c012b8ed>] do_softirq+0x3d/0x50
[ 1500.932813]  [<c0106090>] do_IRQ+0x40/0x70
[ 1500.932813]  [<c010462b>] common_interrupt+0x23/0x28
[ 1500.932813]  [<c01099ef>] mwait_idle+0x2f/0x40
[ 1500.932813]  [<c0102c13>] cpu_idle+0x73/0xf0
[ 1500.932813]  =======================
[ 1500.932813] Code: 76 00 55 89 c5 57 56 53 83 ec 04 89 14 24 8d 74 26
00 8b 45 00 89 c3 83 e3 fc 74 36 8b 13 f6 c2 01 75 2f 89 d7 83 e7 fc 8b
77 08 <39> de 74 53 85 f6 74 2f 8b 06 a8 01 75 29 83 c8 01 89 fd 89 06



> On Wed, Oct 22, 2008 at 10:06:58AM +0400, Badalian Vyacheslav wrote:
>   
>> Hello!
>>     
> Hi!
>
>   
>> I get more information.
>>
>> Statistics of PC:
>> 1. 2.6.26.6 Dunamic Timer, HiResTimer, 1000HZ, htb_hysteresis=0 -
>> crashed 1d 18h ago
>> 2. 2.6.26.5 HZ300, NO Dunamic Timer, No HiResTimer, htb_hysteresis=0 -
>> uptime 5d 17h (no crashes for now, but it crashed some time ago with
>> htb_hysteresis=1)
>>     
>
> So it looks like htb_hysteresis change could be not enough, and it's
> a pity because this could be easiest to "reverse" in the kernel.
>
>   
>> 3. 2.6.27, 1000HZ, NO Dunamic Timer, No HiResTimer, htb_hysteresis=0 +
>> PATCH - uptime 5d 17h (no crashes for now, but it crashed some time ago
>> without patch)
>>     
>
> So I guess this patch seems to make some difference, but it also could
> be hard to convince people to fix it this way, because it makes
> scheduling less exact.
>
> Alas I have still no idea of the real reason. IMHO this should be 
> rather debugged by hrtimers/NMI people, but there were no respose last
> time I Cc-ed them - anyway I added linux-kernel to Cc again here.
>
> I attach below a slightly modified version of the previous patch,
> which lets for more exact scheduling, but could be more vulnerable for
> this bug. Alas, even if it works, it still could be not the final
> solution of this problem.
>
>   
>> Also attach crash log of lash crash PC 1:
>>
>> [10610.110729] BUG: NMI Watchdog detected LOCKUP on CPU1, ip c01fd939,
>> registers:
>> [10610.110729] Modules linked in: netconsole e1000e i2c_i801 i2c_core e1000
>> [10610.110729]
>> [10610.110729] Pid: 0, comm: swapper Not tainted (2.6.26.6-fw #1)
>> [10610.110729] EIP: 0060:[<c01fd939>] EFLAGS: 00000082 CPU: 1
>> [10610.110729] EIP is at rb_insert_color+0x19/0xc0
>>     
>
> Thanks,
> Jarek P.
>
> --- (testing patch #2)
>
>  net/sched/sch_htb.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 30c999c..ff9e965 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -162,6 +162,7 @@ struct htb_sched {
>  
>  	int rate2quantum;	/* quant = rate / rate2quantum */
>  	psched_time_t now;	/* cached dequeue time */
> +	psched_time_t next_watchdog;
>  	struct qdisc_watchdog watchdog;
>  
>  	/* non shaped skbs; let them go directly thru */
> @@ -920,7 +921,11 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
>  		}
>  	}
>  	sch->qstats.overlimits++;
> -	qdisc_watchdog_schedule(&q->watchdog, next_event);
> +	if (q->next_watchdog < q->now || next_event <=
> +	     q->next_watchdog - PSCHED_TICKS_PER_SEC / (10 * HZ)) {
> +		qdisc_watchdog_schedule(&q->watchdog, next_event);
> +		q->next_watchdog = next_event;
> +	}
>  fin:
>  	return skb;
>  }
> @@ -973,6 +978,7 @@ static void htb_reset(struct Qdisc *sch)
>  		}
>  	}
>  	qdisc_watchdog_cancel(&q->watchdog);
> +	q->next_watchdog = 0;
>  	__skb_queue_purge(&q->direct_queue);
>  	sch->q.qlen = 0;
>  	memset(q->row, 0, sizeof(q->row));
>
>   

