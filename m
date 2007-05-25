From: "Sebastien Estienne" <sebastien.estienne@gmail.com>
Subject: Re: [ipvs] BUG: soft lockup detected on CPU#3!
Date: Fri, 25 May 2007 09:30:52 +0000
Message-ID: <446f47c20705250230n6d43b6eu4b163a170fdc6007@mail.gmail.com>
References: <446f47c20705221019j34de745fj9aad8633a6edfd54@mail.gmail.com>
	 <20070525084645.GA14817@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, ja@ssi.bg, nedev <netdev@vger.kernel.org>
To: Horms <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:48623 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbXEYJaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 05:30:55 -0400
Received: by wa-out-1112.google.com with SMTP id j4so307132wah
        for <netdev@vger.kernel.org>; Fri, 25 May 2007 02:30:52 -0700 (PDT)
In-Reply-To: <20070525084645.GA14817@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 5/25/07, Horms <horms@verge.net.au> wrote:
> [Adding netdev CC]
>
> On Tue, May 22, 2007 at 07:19:44PM +0200, Sebastien Estienne wrote:
> > Hello,
> >
> > I have the following bug (stacktrace in the attachment) and i think
> > it's related to ipvs, i reproduced it many time.
> >
> > kernel is from ubuntu: "2.6.20-15-server SMP x86_64"
> > on dell poweredge sc1425
> >
> > i can trigger this bug when i adjust the weight of the real server
> > every 500ms using ipvsadm -R and piping the modifications
> >
> > there is 4 virtual server with 55 realserver each
> >
> > any idea?
>
> Not off hand. Though it does look some what unplesant :(
> I'll try my hand at trying to reproduce the problem.
>
> Is there any chance that you could try a vanilla (2.6.21) kernel
> to see if the problem exists there too?

I didn't try 2.6.21 yet, but using ubuntu dapper kernel (2.6.15) i
can't reproduce the bug.
When i was using feisty kernel (2.6.20), i can reproduce in less than 5 minutes.

I'm using lvs to loadbalance some mysql servers, i wrote a deamon that
check the synchro of the mysql replication on each slave and adjust
the wieght on the lvs every 500ms

> >
> > regards,
> > --
> > Sebastien Estienne
>
> > BUG: soft lockup detected on CPU#3!
> >
> > Call Trace:
> >  <IRQ>  [softlockup_tick+249/288] softlockup_tick+0xf9/0x120
> >  [update_process_times+87/144] update_process_times+0x57/0x90
> >  [smp_local_timer_interrupt+52/96] smp_local_timer_interrupt+0x34/0x60
> >  [smp_apic_timer_interrupt+89/128] smp_apic_timer_interrupt+0x59/0x80
> >  [apic_timer_interrupt+102/112] apic_timer_interrupt+0x66/0x70
> >  <EOI>  [_end+130125309/2130038908] :ip_vs:do_ip_vs_set_ctl+0xad1/0xbf0
> >  [_end+130125305/2130038908] :ip_vs:do_ip_vs_set_ctl+0xacd/0xbf0
> >  [nf_sockopt+233/304] nf_sockopt+0xe9/0x130
> >  [nf_setsockopt+22/32] nf_setsockopt+0x16/0x20
> >  [ip_setsockopt+118/160] ip_setsockopt+0x76/0xa0
> >  [sys_setsockopt+166/240] sys_setsockopt+0xa6/0xf0
> >  [system_call+126/131] system_call+0x7e/0x83
> >
> > BUG: soft lockup detected on CPU#0!
> >
> > Call Trace:
> >  <IRQ>  [softlockup_tick+249/288] softlockup_tick+0xf9/0x120
> >  [update_process_times+87/144] update_process_times+0x57/0x90
> >  [smp_local_timer_interrupt+52/96] smp_local_timer_interrupt+0x34/0x60
> >  [smp_apic_timer_interrupt+89/128] smp_apic_timer_interrupt+0x59/0x80
> >  [_end+130330509/2130038908] :nf_conntrack:nf_ct_invert_tuple+0x51/0xa0
> >  [apic_timer_interrupt+102/112] apic_timer_interrupt+0x66/0x70
> >  [__read_lock_failed+5/32] __read_lock_failed+0x5/0x20
> >  [_read_lock+11/16] _read_lock+0xb/0x10
> >  [_end+130122092/2130038908] :ip_vs:ip_vs_service_get+0x20/0x1e0
> >  [_end+130144732/2130038908] :ip_vs:tcp_conn_schedule+0xa0/0x150
> >  [_end+130144313/2130038908] :ip_vs:tcp_conn_in_get+0x7d/0xc0
> >  [_end+130111414/2130038908] :ip_vs:ip_vs_in+0xca/0x270
> >  [nf_iterate+92/160] nf_iterate+0x5c/0xa0
> >  [ip_local_deliver_finish+0/528] ip_local_deliver_finish+0x0/0x210
> >  [nf_hook_slow+113/240] nf_hook_slow+0x71/0xf0
> >  [ip_local_deliver_finish+0/528] ip_local_deliver_finish+0x0/0x210
> >  [ip_local_deliver+111/656] ip_local_deliver+0x6f/0x290
> >  [ip_rcv+1246/1360] ip_rcv+0x4de/0x550
> >  [netif_receive_skb+623/800] netif_receive_skb+0x26f/0x320
> >  [_end+129188049/2130038908] :e1000:e1000_clean_rx_irq+0x445/0x520
> >  [_end+129183152/2130038908] :e1000:e1000_clean+0x84/0x2b0
> >  [net_rx_action+186/512] net_rx_action+0xba/0x200
> >  [__do_softirq+95/208] __do_softirq+0x5f/0xd0
> >  [call_softirq+28/40] call_softirq+0x1c/0x28
> >  [do_softirq+44/144] do_softirq+0x2c/0x90
> >  [do_IRQ+217/256] do_IRQ+0xd9/0x100
> >  [mwait_idle+0/80] mwait_idle+0x0/0x50
> >  [ret_from_intr+0/10] ret_from_intr+0x0/0xa
> >  <EOI>  [tcp_poll+0/336] tcp_poll+0x0/0x150
> >  [mwait_idle+66/80] mwait_idle+0x42/0x50
> >  [cpu_idle+155/208] cpu_idle+0x9b/0xd0
> >  [start_kernel+586/608] start_kernel+0x24a/0x260
> >  [x86_64_start_kernel+358/368] _sinittext+0x166/0x170
> >
>
>
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
>
>


-- 
Sebastien Estienne
