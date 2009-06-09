From: "Yu, Fenghua" <fenghua.yu@intel.com>
Subject: Re: [BUG] ixgbe triggering iommu/vt-d BUG()
Date: Tue, 9 Jun 2009 11:40:53 -0700
Message-ID: <A6AD88C3F2289247BE726C37303E1EB8AFCF6DB2@orsmsx505.amr.corp.intel.com>
References: <20090608212526.GJ20823@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'e1000-devel@lists.sourceforge.net'" <e1000-devel@lists.sourceforge.net>,
	"'iommu@lists.linux-foundation.org'" <iommu@lists.linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: 'Chris Wright' <chrisw@sous-sol.org>, "'netdev@vger.kernel.org'"
	<netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090608212526.GJ20823@sequoia.sous-sol.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>simple ping works...netperf TCP_STREAM test quickly triggers this:
>(this is current -linus tree, v2.6.30-rc8-73-g3af968e)
>
>[  116.554402] kernel BUG at drivers/pci/intel-iommu.c:1524!
>[  116.560052] invalid opcode: 0000 [#1] SMP
>[  116.564522] last sysfs file:
>/sys/devices/system/cpu/cpu15/cache/index2/shared_cpu_map
>[  116.572845] CPU 11
>[  116.575162] Modules linked in: kvm_intel kvm igb ixgbe
>[  116.580873] Pid: 0, comm: swapper Not tainted 2.6.30-rc8 #2 X8DTN
>[  116.587254] RIP: 0010:[<ffffffff811ccc4a>]  [<ffffffff811ccc4a>]
>domain_page_mapping+0xa1/0x103
>[  116.596418] RSP: 0018:ffffc200000dfca0  EFLAGS: 00010206
>[  116.601901] RAX: 00000001b0ceb002 RBX: 00000000001b4366 RCX:
>000000000000000c
>[  116.609176] RDX: 00000001b0cea000 RSI: ffff8801b0ceaff0 RDI:
>ffff8801bcd42748
>[  116.616518] RBP: ffffc200000dfce0 R08: 0000000000000002 R09:
>0000000000000102
>[  116.623801] R10: 0000000000000000 R11: ffffffff81732bb0 R12:
>00000001b4366000
>[  116.631154] R13: 00000000001b4367 R14: 0000000000000002 R15:
>ffff8801bcd42700
>[  116.638439] FS:  0000000000000000(0000) GS:ffffc200000dc000(0000)
>knlGS:0000000000000000
>[  116.646708] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>[  116.652598] CR2: 0000000001061000 CR3: 000000033d565000 CR4:
>00000000000026e0
>[  116.659888] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>0000000000000000
>[  116.667242] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>0000000000000400
>[  116.674536] Process swapper (pid: 0, threadinfo ffff88033f076000, task
>ffff8801bf0f0ea0)
>[  116.682793] Stack:
>[  116.684904]  ffffc200000dfce0 00000000001b4366 00000000efffe000
>0000000000001000
>[  116.692517]  00000001b4366422 00000000efffe000 ffff8801bcd42700
>ffff8801ba5feac0
>[  116.700406]  ffffc200000dfd40 ffffffff811cd702 ffffc200000dfd30
>00000002813b448b
>[  116.708553] Call Trace:
>[  116.711090]  <IRQ> <0> [<ffffffff811cd702>]
>__intel_map_single+0xeb/0x169
>[  116.718285]  [<ffffffff811cd821>] ? intel_map_page+0x0/0x3e
>[  116.724272]  [<ffffffff811cd85d>] intel_map_page+0x3c/0x3e
>[  116.730162]  [<ffffffffa00013ca>] ixgbe_alloc_rx_buffers+0x18d/0x23a
>[ixgbe]
>[  116.737610]  [<ffffffffa0002749>] ixgbe_clean_rx_irq+0x3e9/0x41b [ixgbe]
>[  116.744685]  [<ffffffffa0004c58>] ixgbe_clean_rxonly+0x51/0xa0 [ixgbe]
>[  116.751588]  [<ffffffff813bd267>] net_rx_action+0xa8/0x15d
>[  116.757391]  [<ffffffff810411b7>] __do_softirq+0x9d/0x15f
>[  116.763096]  [<ffffffff8100cbfc>] call_softirq+0x1c/0x28
>[  116.768619]  [<ffffffff8100e01d>] do_softirq+0x34/0x73
>[  116.773949]  [<ffffffff81041078>] irq_exit+0x3f/0x7e
>[  116.779129]  [<ffffffff8100dd9a>] do_IRQ+0x9d/0xb4
>[  116.784088]  [<ffffffff8100c4d3>] ret_from_intr+0x0/0xa
>[  116.789466]  <EOI> <0> [<ffffffff812097cc>] ?
>acpi_idle_enter_bm+0x1f9/0x225
>[  116.796948]  [<ffffffff812097c2>] ? acpi_idle_enter_bm+0x1ef/0x225
>[  116.803575]  [<ffffffff8134f3b4>] ? cpuidle_idle_call+0x73/0xab
>[  116.809819]  [<ffffffff8100ac27>] ? cpu_idle+0x52/0x81
>[  116.815287]  [<ffffffff814c113a>] ? start_secondary+0x17f/0x184
>[  116.821542] Code: 89 55 c8 eb 6d 48 63 f0 4c 89 ff 48 c1 e6 0c 48 03 75
>d0 e8 2d fe ff ff 48 85 c0 48 89 c6 74 99 48 8b 00 48 a9 00 f0 ff ff 74 04
><0f> 0b eb fe 4c 89 e2 48 81 e2 00 f0 ff ff 48 09 c2 4c 89 f0 48
>[  116.842465] RIP  [<ffffffff811ccc4a>] domain_page_mapping+0xa1/0x103
>[  116.849126]  RSP <ffffc200000dfca0>

I also see this issue on 2.6.30-rc8. After I upgrade the ixgbe driver to ixgbe-1.3.56.17, I couldn't see the issue any more. Netperf is running ok for me now.

You can find ixgbe-1.3.56.17 or other versions from:
http://downloadcenter.intel.com/Product_Search.aspx?Prod_nm=ixgbe&page_nbr=1&lang=eng

I hope 10Gigabit driver maintainer will push the changes to upstream.

Thanks.

-Fenghua

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
