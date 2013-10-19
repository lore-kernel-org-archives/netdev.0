From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Sat, 19 Oct 2013 22:52:22 +0200
Message-ID: <20131019205222.GA18874@redhat.com>
References: <20131019202702.GA8354@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab3JSUyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Oct 2013 16:54:36 -0400
Content-Disposition: inline
In-Reply-To: <20131019202702.GA8354@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 10:27:02PM +0200, Thomas Glanzmann wrote:
>Hello,
>I'm referring to commit 7864a1adf7291993d74923fdd0a45459ce9da27e. I just
>checked out the tip from Linus tree compiled it and run it on Debian Wheezy
>with 4 1 GBIT NICs, two connected to one switch and two to another. I
>configured bonding to use tlb. On the ports is one untagged and one
>tagged VLAN. When I boot the kernel even if only one NIC is attached I
>get multiple failed assertions:
>
...snip...
>[   19.080783] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
>[   19.080868] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.12.0-rc5+ #1
>[   19.080944] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
>[   19.081022]  0000000000000000 0000000000000000 ffffffff81373aba ffff88103e1a0000
>[   19.081316]  ffffffffa040aea2 ffff88103e1a0000 0000000000000000 ffff88103e1a0000
>[   19.081607]  ffffffff812c54f5 00000000ffffffff ffff88107fc83c90 ffff88107f000480
>[   19.081912] Call Trace:
>[   19.081982]  <IRQ>  [<ffffffff81373aba>] ? dump_stack+0x41/0x51
>[   19.082176]  [<ffffffffa040aea2>] ? bond_set_rx_mode+0x2d/0xa7 [bonding]
>[   19.082258]  [<ffffffff812c54f5>] ? __dev_mc_add+0x48/0x59
>[   19.082337]  [<ffffffff8134d4ee>] ? igmp6_group_added+0x65/0x17d
>[   19.082418]  [<ffffffff810fc836>] ? kmem_cache_alloc_trace+0xbb/0xcb
>[   19.082497]  [<ffffffff8134e7dd>] ? ipv6_dev_mc_inc+0x20e/0x236
>[   19.082578]  [<ffffffff81339f70>] ? addrconf_join_solict+0x2e/0x33
>[   19.082656]  [<ffffffff81332e22>] ? ipv6_dev_ac_inc+0x131/0x16f
>[   19.082735]  [<ffffffff81336f67>] ? addrconf_join_anycast+0x38/0x3e
>[   19.082814]  [<ffffffff8133a0b1>] ? __ipv6_ifa_notify+0x106/0x234
>[   19.082893]  [<ffffffff8133a20d>] ? ipv6_ifa_notify+0x2e/0x37
>[   19.082971]  [<ffffffff8133a660>] ? addrconf_dad_completed+0x32/0x185
>[   19.083050]  [<ffffffff8133a874>] ? addrconf_dad_timer+0xc1/0x13c
>[   19.083129]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
>[   19.083210]  [<ffffffff81040613>] ? call_timer_fn+0x4b/0xf6
>[   19.083288]  [<ffffffff8133a7b3>] ? addrconf_dad_completed+0x185/0x185
>[   19.083367]  [<ffffffff81040c04>] ? run_timer_softirq+0x189/0x1ce
>[   19.083448]  [<ffffffff8107c7dd>] ? tick_sched_do_timer+0x25/0x25
>[   19.083527]  [<ffffffff8103ad68>] ? __do_softirq+0xe8/0x201
>[   19.083606]  [<ffffffff81075d98>] ? ktime_get+0x5f/0x6b
>[   19.083682]  [<ffffffff8107afca>] ? clockevents_program_event+0x9a/0xb6
>[   19.083761]  [<ffffffff8137df5c>] ? call_softirq+0x1c/0x30
>[   19.083839]  [<ffffffff81003b7c>] ? do_softirq+0x2c/0x60
>[   19.083916]  [<ffffffff8103af46>] ? irq_exit+0x3b/0x7f
>[   19.083994]  [<ffffffff81023b19>] ? smp_apic_timer_interrupt+0x2c/0x37
>[   19.084074]  [<ffffffff8137d48a>] ? apic_timer_interrupt+0x6a/0x70
>[   19.084149]  <EOI>  [<ffffffff8129a6b1>] ? cpuidle_enter_state+0x43/0xa6
>[   19.084330]  [<ffffffff8129a6aa>] ? cpuidle_enter_state+0x3c/0xa6
>[   19.084408]  [<ffffffff8129a7e6>] ? cpuidle_idle_call+0xd2/0x142
>[   19.084486]  [<ffffffff81008ff9>] ? arch_cpu_idle+0x6/0x17
>[   19.084563]  [<ffffffff8106f7e9>] ? cpu_startup_entry+0x10d/0x180
>[   19.084641]  [<ffffffff8137780c>] ? _raw_spin_unlock_irqrestore+0x6/0x7
>[   19.084726]  [<ffffffff810226dd>] ? start_secondary+0x1df/0x1e5

Fixed in commit b32418705107265dfca5edfe2b547643e53a732e ("bonding: RCUify
bond_set_rx_mode()") net-next. It should get into mainline soon.

...snip...
>Howto reproduce:
>
>        - Build the kernel from Torvalds tip
>        - Configure bonding with tlb with one NIC.
>
>auto bond0
>iface bond0 inet static
>        address ...
>        netmask ...
>        network ...
>        broadcast  ...
>        gateway ...
>        bond-mode balance-tlb
>        bond-miimon 100
>        slaves eth0
>        # eth1 eth2 eth3
>
>Cheers,
>        Thomas
