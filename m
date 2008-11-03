From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: xfrm_policy_kill: inconsistent {softirq-on-W} ->	{in-softirq-W}
 usage
Date: Mon, 03 Nov 2008 21:20:16 +0000
Message-ID: <490F6B10.9070902@simon.arlott.org.uk>
References: <490F3C08.6000209@simon.arlott.org.uk> <20081103205726.GA3589@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:56276 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572AbYKCVUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 16:20:20 -0500
In-Reply-To: <20081103205726.GA3589@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/08 20:57, Alexey Dobriyan wrote:
> On Mon, Nov 03, 2008 at 05:59:36PM +0000, Simon Arlott wrote:
>> [163040.503328] =================================
>> [163040.504264] [ INFO: inconsistent lock state ]
>> [163040.504264] 2.6.28-rc2-git #19424-g083ead5
>> [163040.504264] ---------------------------------
>> [163040.504264] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
>> [163040.504264] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>> [163040.531914]  (xfrm_policy_gc_lock){-+..}, at: [<7846bf3f>] xfrm_policy_kill+0x46/0x7e
> 
> If it's easily reproducible, try this patch:

Unfortunately I don't know how to reproduce it and I won't reboot that system 
to apply a patch. I've checked my logs and can find only one other instance 
of that message, from 5 months ago:

12 00:56:17 [461680.399422] =================================
12 00:56:17 [461680.405467] [ INFO: inconsistent lock state ]
12 00:56:17 [461680.409910] 2.6.23.9-git #44
12 00:56:17 [461680.412876] ---------------------------------
12 00:56:17 [461680.417315] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
12 00:56:17 [461680.423403] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
12 00:56:17 [461680.428450]  (xfrm_policy_gc_lock){-+..}, at: [<803355f6>] xfrm_policy_kill+0x63/0x9e
12 00:56:17 [461680.436442] {softirq-on-W} state was registered at:
12 00:56:17 [461680.441401]   [<80131712>] __lock_acquire+0x471/0xb96
12 00:56:18 [461680.446591]   [<80132200>] lock_acquire+0x5d/0x75
12 00:56:18 [461680.451431]   [<8038b2e7>] _spin_lock+0x35/0x42
12 00:56:18 [461680.456098]   [<803355f6>] xfrm_policy_kill+0x63/0x9e
12 00:56:18 [461680.461287]   [<8033570b>] xfrm_policy_delete+0x43/0x49
12 00:56:18 [461680.466648]   [<802c0ef7>] sk_common_release+0x61/0x9e
12 00:56:18 [461680.471925]   [<80310328>] udp_lib_close+0x8/0xa
12 00:56:18 [461680.476677]   [<8031709d>] inet_release+0x42/0x48
12 00:56:18 [461680.481519]   [<802bf269>] sock_release+0x17/0x80
12 00:56:18 [461680.486453]   [<802bf726>] sock_close+0x2d/0x33
12 00:56:18 [461680.491119]   [<80158838>] __fput+0xb9/0x185
12 00:56:18 [461680.495527]   [<8015891a>] fput+0x16/0x18
12 00:56:18 [461680.499668]   [<801561d3>] filp_close+0x54/0x5c
12 00:56:18 [461680.504341]   [<80157334>] sys_close+0x6e/0xa6
12 00:56:18 [461680.508916]   [<80102702>] sysenter_past_esp+0x5f/0x99
12 00:56:18 [461680.514189]   [<ffffffff>] 0xffffffff
12 00:56:18 [461680.517995] irq event stamp: 2352088264
12 00:56:18 [461680.521915] hardirqs last  enabled at (2352088264): [<8011c626>] local_bh_enable_ip+0xc5/0xe1
12 00:56:18 [461680.530552] hardirqs last disabled at (2352088263): [<8011c5bf>] local_bh_enable_ip+0x5e/0xe1
12 00:56:18 [461680.539205] softirqs last  enabled at (2352088198): [<8011c07e>] __do_softirq+0xa3/0xa8
12 00:56:18 [461680.547318] softirqs last disabled at (2352088207): [<8011c0b2>] do_softirq+0x2f/0x47
12 00:56:18 [461680.555262] 
12 00:56:18 [461680.555263] other info that might help us debug this:
12 00:56:18 [461680.562055] no locks held by swapper/0.
12 00:56:18 [461680.565975] 
12 00:56:18 [461680.565977] stack backtrace:
12 00:56:18 [461680.570523]  [<80103694>] show_trace_log_lvl+0x1a/0x2f
12 00:56:18 [461680.575762]  [<8010421b>] show_trace+0x12/0x14
12 00:56:18 [461680.580308]  [<80104232>] dump_stack+0x15/0x17
12 00:56:18 [461680.584853]  [<801302fc>] print_usage_bug+0x143/0x14d
12 00:56:18 [461680.590005]  [<8013093a>] mark_lock+0x125/0x44f
12 00:56:18 [461680.594637]  [<801316a0>] __lock_acquire+0x3ff/0xb96
12 00:56:18 [461680.599702]  [<80132200>] lock_acquire+0x5d/0x75
12 00:56:18 [461680.604421]  [<8038b2e7>] _spin_lock+0x35/0x42
12 00:56:18 [461680.608962]  [<803355f6>] xfrm_policy_kill+0x63/0x9e
12 00:56:18 [461680.614027]  [<8033570b>] xfrm_policy_delete+0x43/0x49
12 00:56:18 [461680.619267]  [<80336c54>] xfrm_policy_timer+0x199/0x1cc
12 00:56:18 [461680.624590]  [<8011f1bd>] run_timer_softirq+0xf1/0x14e
12 00:56:18 [461680.629828]  [<8011c02c>] __do_softirq+0x51/0xa8
12 00:56:18 [461680.634548]  [<8011c0b2>] do_softirq+0x2f/0x47
12 00:56:18 [461680.639093]  [<8011c2de>] irq_exit+0x3b/0x47
12 00:56:18 [461680.643466]  [<8010d252>] smp_apic_timer_interrupt+0x69/0x74
12 00:56:18 [461680.649228]  [<801031af>] apic_timer_interrupt+0x33/0x38
12 00:56:18 [461680.654640]  [<8020b28b>] acpi_processor_idle+0x157/0x3e8
12 00:56:18 [461680.660141]  [<80100b8e>] cpu_idle+0x46/0x6f
12 00:56:18 [461680.664510]  [<803889e8>] rest_init+0x60/0x62
12 00:56:18 [461680.668972]  [<804c2a16>] start_kernel+0x239/0x23f
12 00:56:18 [461680.673870]  [<00000000>] 0x0
12 00:56:18 [461680.677025]  =======================

-- 
Simon Arlott
