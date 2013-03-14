From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Fri, 15 Mar 2013 00:19:34 +0100
Message-ID: <1363303174.29475.46.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
	     <51356AC1.4090302@gmail.com>
	   <1362460046.15793.111.camel@edumazet-glaptop>
	    <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
	   <1362494795.15793.113.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303061631290.6723@dflat>
	  <1362663990.15793.208.camel@edumazet-glaptop>
	  <alpine.DEB.2.02.1303141359080.16308@dflat>
	 <1363301786.29475.40.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141610490.16308@dflat>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1303141610490.16308@dflat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-14 at 16:15 -0700, dormando wrote:

> *sigh*. it's been a long month, sorry:
> 
> [58377.436522] IPv4: Attempt to release TCP socket family 2 in state 1
> ffff8813fbad9500
> [58377.436539] ------------[ cut here ]------------
> [58377.436545] WARNING: at net/ipv4/af_inet.c:146
> inet_sock_destruct+0x176/0x200()
> [58377.436546] Hardware name: X9DR3-F
> [58377.436547] Modules linked in: bridge coretemp ghash_clmulni_intel
> ipmi_watchdog ipmi_devintf gpio_ich microcode ixgbe sb_edac edac_core mei
> lpc_ich mfd_core mdio ipmi_si ipmi_msghandler iptable_nat nf_nat_ipv4
> nf_nat isci libsas igb ptp pps_core
> [58377.436563] Pid: 0, comm: swapper/0 Not tainted 3.8.2 #3
> [58377.436564] Call Trace:
> [58377.436566]  <IRQ>  [<ffffffff8104964f>] warn_slowpath_common+0x7f/0xc0
> [58377.436572]  [<ffffffff810496aa>] warn_slowpath_null+0x1a/0x20
> [58377.436574]  [<ffffffff816032e6>] inet_sock_destruct+0x176/0x200
> [58377.436578]  [<ffffffff815ec8e0>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [58377.436581]  [<ffffffff8156ee8d>] __sk_free+0x1d/0x140
> [58377.436583]  [<ffffffff815ec8e0>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [58377.436585]  [<ffffffff8156efd5>] sk_free+0x25/0x30
> [58377.436586]  [<ffffffff815ec929>] tcp_write_timer+0x49/0x70
> [58377.436590]  [<ffffffff81059259>] call_timer_fn+0x49/0x130
> [58377.436593]  [<ffffffff8107a07f>] ? scheduler_tick+0x15f/0x190
> [58377.436596]  [<ffffffff81059854>] run_timer_softirq+0x224/0x290
> [58377.436598]  [<ffffffff81058f76>] ? update_process_times+0x76/0x90
> [58377.436600]  [<ffffffff815ec8e0>] ? tcp_write_timer_handler+0x1b0/0x1b0
> [58377.436602]  [<ffffffff8108ebd4>] ? ktime_get+0x54/0xe0
> [58377.436604]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [58377.436608]  [<ffffffff8168fd4c>] call_softirq+0x1c/0x30
> [58377.436611]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [58377.436613]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [58377.436616]  [<ffffffff8169036e>] smp_apic_timer_interrupt+0x6e/0x99
> [58377.436618]  [<ffffffff8168f74a>] apic_timer_interrupt+0x6a/0x70
> [58377.436619]  <EOI>  [<ffffffff816855cc>] ? __schedule+0x3ac/0x750
> [58377.436625]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [58377.436627]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [58377.436629]  [<ffffffff816736a2>] rest_init+0x72/0x80
> [58377.436633]  [<ffffffff81cc7d0e>] start_kernel+0x3ac/0x3b9
> [58377.436635]  [<ffffffff81cc7790>] ? repair_env_string+0x5b/0x5b
> [58377.436636]  [<ffffffff81cc732d>] x86_64_start_reservations+0x131/0x136
> [58377.436638]  [<ffffffff81cc741f>] x86_64_start_kernel+0xed/0xf4
> [58377.436639] ---[ end trace 9e57364162374433 ]---
> 
> ^ pretty sure that's the WARN_ON_ONCE(1)
> 
> Then a short while later the usual:
> 
> [58394.689801] ------------[ cut here ]------------
> [58394.689817] WARNING: at net/sched/sch_generic.c:254
> dev_watchdog+0x258/0x270()
> [58394.689820] Hardware name: X9DR3-F
> [58394.689836] NETDEV WATCHDOG: eth2 (ixgbe): transmit queue 14 timed out
> [58394.689837] Modules linked in: bridge coretemp ghash_clmulni_intel
> ipmi_watchdog ipmi_devintf gpio_ich microcode ixgbe sb_edac edac_core mei
> lpc_ich mfd_core mdio ipmi_si ipmi_msghandler iptable_nat nf_nat_ipv4
> nf_nat isci libsas igb ptp pps_core
> [58394.689853] Pid: 0, comm: swapper/0 Tainted: G        W
> 3.8.2 #3
> [58394.689854] Call Trace:
> [58394.689856]  <IRQ>  [<ffffffff8104964f>] warn_slowpath_common+0x7f/0xc0
> [58394.689863]  [<ffffffff81049746>] warn_slowpath_fmt+0x46/0x50
> [58394.689865]  [<ffffffff815a1508>] dev_watchdog+0x258/0x270
> [58394.689868]  [<ffffffff815a12b0>] ? __netdev_watchdog_up+0x80/0x80
> [58394.689872]  [<ffffffff81059259>] call_timer_fn+0x49/0x130
> [58394.689875]  [<ffffffff8107a07f>] ? scheduler_tick+0x15f/0x190
> [58394.689877]  [<ffffffff81059854>] run_timer_softirq+0x224/0x290
> [58394.689880]  [<ffffffff81058f76>] ? update_process_times+0x76/0x90
> [58394.689882]  [<ffffffff815a12b0>] ? __netdev_watchdog_up+0x80/0x80
> [58394.689884]  [<ffffffff8108ebd4>] ? ktime_get+0x54/0xe0
> [58394.689886]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [58394.689890]  [<ffffffff8168fd4c>] call_softirq+0x1c/0x30
> [58394.689894]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [58394.689895]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [58394.689898]  [<ffffffff8169036e>] smp_apic_timer_interrupt+0x6e/0x99
> [58394.689900]  [<ffffffff8168f74a>] apic_timer_interrupt+0x6a/0x70
> [58394.689901]  <EOI>  [<ffffffff816855cc>] ? __schedule+0x3ac/0x750
> [58394.689907]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [58394.689909]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [58394.689911]  [<ffffffff816736a2>] rest_init+0x72/0x80
> [58394.689915]  [<ffffffff81cc7d0e>] start_kernel+0x3ac/0x3b9
> [58394.689917]  [<ffffffff81cc7790>] ? repair_env_string+0x5b/0x5b
> [58394.689918]  [<ffffffff81cc732d>] x86_64_start_reservations+0x131/0x136
> [58394.689920]  [<ffffffff81cc741f>] x86_64_start_kernel+0xed/0xf4
> [58394.689922] ---[ end trace 9e57364162374434 ]---
> [58394.689965] ixgbe 0000:83:00.0 eth2: Reset adapter
> [58447.665326] INFO: rcu_sched self-detected stall on CPU { 8}  (t=15001
> jiffies g=3607787 c=3607786 q=332913)
> 
> (then tons of stuck processes getting timed out)

Thanks thats really useful, we might miss to increment socket refcount
in a timer setup.
