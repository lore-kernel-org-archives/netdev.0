From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Mon, 25 Sep 2006 14:43:52 +0200
Message-ID: <20060925124352.GA1592@ff.dom.local>
References: <20060924212933.GB20123@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:3721 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1750770AbWIYMjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 08:39:39 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060924212933.GB20123@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24-09-2006 23:29, Dave Jones wrote:
> =================================
> [ INFO: inconsistent lock state ]
> ---------------------------------
> inconsistent {softirq-on-R} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
>  (police_lock){-+--}, at: [<f8d304fd>] tcf_police_destroy+0x24/0x8f [act_police]
> {softirq-on-R} state was registered at:
>   [<c043bdd6>] lock_acquire+0x4b/0x6d
>   [<c061495a>] _read_lock+0x19/0x28
>   [<f8d3026a>] tcf_act_police_locate+0x26a/0x363 [act_police]
...
>  [<c06148a5>] _write_lock_bh+0x1e/0x2d
>  [<f8d304fd>] tcf_police_destroy+0x24/0x8f [act_police]
...
>  [<c042900f>] __do_softirq+0x78/0xf2
>  [<c0406683>] do_softirq+0x5a/0xbe
>  [<c0428eb8>] irq_exit+0x3d/0x3f
>  [<c04179df>] smp_apic_timer_interrupt+0x73/0x78
>  [<c0404b12>] apic_timer_interrupt+0x2a/0x30
> DWARF2 unwinder stuck at apic_timer_interrupt+0x2a/0x30
> Leftover inexact backtrace:

It's probably 2.6.18 and should change a little now (git4) but
IMHO main problem stays: it looks tcf_act_police_locate in
act_police.c was preempted in read_lock (tcf_police_lookup)
- now the same is possible in tcf_hash_lookup. So maybe
read_lock_bh will help?

Jarek P. 
