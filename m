From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH]  hrtimer, softirq: Fix hrtimer->softirq trampoline
Date: Wed, 03 Feb 2010 09:47:38 +0800
Message-ID: <4B68D5BA.5030707@cn.fujitsu.com>
References: <4B66A670.70503@cn.fujitsu.com>	 <20100202074914.GD11081@gondor.apana.org.au>	 <20100202085117.7a5c3530@penta.localdomain> <1265120401.24455.306.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yury Polyanskiy <ypolyans@princeton.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, polyanskiy@gmail.com,
	Thomas Gleixner <tglx@linutronix.de>,
	lkml <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56505 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932219Ab0BCBqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 20:46:09 -0500
In-Reply-To: <1265120401.24455.306.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> On Tue, 2010-02-02 at 08:51 -0500, Yury Polyanskiy wrote:
>
> The original email had more information:
>
>   
>> {IN-HARDIRQ-W} state was registered at:
>>   [<c04718dc>] __lock_acquire+0xa9c/0x1890
>>   [<c047274f>] lock_acquire+0x7f/0xf0
>>   [<c0762958>] _raw_spin_lock+0x38/0x50
>>   [<c072b5ca>] xfrm_timer_handler+0x3a/0x260
>>   [<c0447d9d>] __hrtimer_tasklet_trampoline+0xd/0x10
>>   [<c04634ce>] hrtimer_run_queues+0x15e/0x2a0
>>   [<c045146d>] run_local_timers+0xd/0x20
>>   [<c04514b4>] update_process_times+0x34/0x70
>>   [<c046ce8a>] tick_periodic+0x2a/0x80
>>   [<c046cefe>] tick_handle_periodic+0x1e/0x90
>>   [<c0768377>] smp_apic_timer_interrupt+0x57/0x8b
>>   [<c076382f>] apic_timer_interrupt+0x2f/0x34
>>   [<c0401d3b>] cpu_idle+0x4b/0x80
>>   [<c074e0d7>] rest_init+0x67/0x70
>>   [<c0956874>] start_kernel+0x30e/0x314
>>   [<c095609e>] i386_start_kernel+0x9e/0xa5
>>     
>
> Which indicates we were called from hardirq context, it appears that
> that hrtimer_is_hres_active() case is indeed faulty. Not sure if I made
> a mistake when I wrote that or if we changed hrtimer behaviour
> afterwards, but the hrtimer fallback is still from hardirq context.
>
> Which would seem to suggest the following patch:
>
> ---
> Subject: hrtimer, softirq: Fix hrtimer->softirq trampoline
>
> hrtimers callbacks are always done from hardirq context, either the
> jiffy tick interrupt or the hrtimer device interrupt.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
>   

With this patch, the inconsistent lock state INFO is gone. Thanks.

Wei Yongjun

