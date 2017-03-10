From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: amd-xgbe: unbalanced irq enable in v4.11-rc1
Date: Fri, 10 Mar 2017 11:39:42 -0600
Message-ID: <6ded1511-af84-e406-7e86-dd84972c451d@amd.com>
References: <20170310171953.GA24571@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Mark Rutland <mark.rutland@arm.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0076.outbound.protection.outlook.com ([104.47.41.76]:37944
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932912AbdCJRjx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 12:39:53 -0500
In-Reply-To: <20170310171953.GA24571@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/2017 11:19 AM, Mark Rutland wrote:
> Hi,
>
> I'm seeing the below splat when transferring data over the network, using
> v4.11-rc1 on an AMD Seattle platform. I don't see the splat with v4.10.
>
> Looking at just the driver, I couldn't see any suspicious changes. Reverting
> commit 402168b4c2dc0734 ("amd-xgbe: Stop the PHY before releasing interrupts")
> doesn't change matters.
>
> Any ideas?

Yes, patch submitted.  Please see:

	http://marc.info/?l=linux-netdev&m=148910333810442&w=2

Thanks,
Tom

>
> Thanks,
> Mark.
>
> [  106.114135] Unbalanced enable for IRQ 34
> [  106.118157] ------------[ cut here ]------------
> [  106.122793] WARNING: CPU: 0 PID: 0 at kernel/irq/manage.c:529 __enable_irq+0x168/0x1d8
> [  106.130708] Modules linked in:
> [  106.133766]
> [  106.135262] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.11.0-rc1-00001-g2411f70 #5
> [  106.142830] Hardware name: AMD Seattle (Rev.B0) Development Board (Overdrive) (DT)
> [  106.150398] task: ffff20000a9e2000 task.stack: ffff20000a9c0000
> [  106.156320] PC is at __enable_irq+0x168/0x1d8
> [  106.160679] LR is at __enable_irq+0x168/0x1d8
> [  106.165036] pc : [<ffff2000082a1340>] lr : [<ffff2000082a1340>] pstate: 000001c5
> [  106.172428] sp : ffff8003fff17c50
> [  106.175742] x29: ffff8003fff17c50 x28: ffff800359255160
> [  106.181063] x27: 1ffff0006b24aa2d x26: ffff800359255170
> [  106.186385] x25: ffff20000a9ca000 x24: ffff800359255168
> [  106.191706] x23: ffff80036902ca80 x22: ffff80036bbe8f78
> [  106.197027] x21: 1ffff0006d77d1ef x20: 0000000000000000
> [  106.202348] x19: ffff80036bbe8f00 x18: ffff20000a9e27b8
> [  106.207668] x17: 0000ffff7e2b5d90 x16: 0000000000000000
> [  106.212989] x15: 1fffe4000153c4f7 x14: 00006003f5590000
> [  106.218310] x13: ffff20000ac45000 x12: ffff20000b803000
> [  106.223631] x11: 1fffe40001ba7a8d x10: 0000000000000000
> [  106.228951] x9 : ffff10007ffe2ee0 x8 : ffff20000a9e27e8
> [  106.234272] x7 : ffff20000d2d3000 x6 : 0000000000000000
> [  106.239592] x5 : 0000000041b58ab3 x4 : 1fffe40001ba3a10
> [  106.244913] x3 : 1fffe40001ba3a10 x2 : dfff200000000000
> [  106.250234] x1 : ffff10007ffe2f58 x0 : 000000000000001c
> [  106.255553]
> [  106.257044] ---[ end trace 86935ef2e5e5c498 ]---
> [  106.261658] Call trace:
> [  106.264106] Exception stack(0xffff8003fff17a00 to 0xffff8003fff17b30)
> [  106.270550] 7a00: ffff80036bbe8f00 0001000000000000 ffff8003fff17c50 ffff2000082a1340
> [  106.278383] 7a20: 00000000000001c5 000000000000003d ffff20000a9ca000 ffff800359255170
> [  106.286216] 7a40: 1ffff0006b24aa2d ffff20000a9e2000 ffff8003fff17b60 0000ffff73870f20
> [  106.294048] 7a60: 0000000041b58ab3 ffff20000a7164f0 ffff200008081ac8 ffff20000a05d4a0
> [  106.301881] 7a80: ffff80036902ca80 ffff800359255168 ffff20000a9ca000 ffff800359255170
> [  106.309713] 7aa0: ffff8003fff17c50 ffff8003fff17c50 ffff8003fff17c10 00000000ffffffc8
> [  106.317546] 7ac0: 0000000041b58ab3 ffff20000a72a340 ffff200008299380 ffff20000a9e2000
> [  106.325379] 7ae0: ffff8003fff17b20 ffff200008bf8f08 ffff80036bbe8f00 ffff80036d8002c0
> [  106.333211] 7b00: ffff80036d8003f8 1ffff0007ffe2f70 0000000000000000 0000000000000000
> [  106.341040] 7b20: 000000000000001c ffff10007ffe2f58
> [  106.345921] [<ffff2000082a1340>] __enable_irq+0x168/0x1d8
> [  106.351323] [<ffff2000082a1458>] enable_irq+0xa8/0x118
> [  106.356467] [<ffff2000094c8950>] xgbe_one_poll+0x190/0x280
> [  106.361956] [<ffff200009c7a944>] net_rx_action+0x6ac/0xd88
> [  106.367444] [<ffff20000808266c>] __do_softirq+0x324/0xb70
> [  106.372845] [<ffff20000815908c>] irq_exit+0x1cc/0x338
> [  106.377900] [<ffff20000829acdc>] __handle_domain_irq+0xdc/0x230
> [  106.383821] [<ffff2000080820f4>] gic_handle_irq+0x6c/0xe0
> [  106.389220] Exception stack(0xffff20000a9c3d40 to 0xffff20000a9c3e70)
> [  106.395663] 3d40: ffff20000a9e27bc 0000000000000007 0000000000000000 1fffe4000153c4f7
> [  106.403495] 3d60: 0000000000000004 0000000000000000 0000000000000000 ffff20000d2d3000
> [  106.411327] 3d80: ffff20000a9e27c0 ffff040001538762 0000000000000000 0000000000000003
> [  106.419160] 3da0: ffff20000b803000 ffff20000ac45000 1ffff0007ffe4281 1fffe4000153c4f7
> [  106.426992] 3dc0: 0000000000000000 0000ffff7e2b5d90 ffff20000a9e27b8 ffff20000a9e2000
> [  106.434824] 3de0: ffff20000a9e2000 0000000000000000 ffff20000a9cfeb0 0000000000000003
> [  106.442656] 3e00: 00000000000000ff ffff20000a9cfe18 ffff20000a901058 0000000000000000
> [  106.450488] 3e20: 0000008004810018 ffff20000a9c3e70 ffff20000808a1d8 ffff20000a9c3e70
> [  106.458321] 3e40: ffff20000808a1dc 0000000060000145 0000000000000000 ffff20000a901058
> [  106.466150] 3e60: ffffffffffffffff ffff20000808a1d8
> [  106.471029] [<ffff200008083ff8>] el1_irq+0xb8/0x130
> [  106.475909] [<ffff20000808a1dc>] arch_cpu_idle+0x1c/0x28
> [  106.481225] [<ffff200009ffd27c>] default_idle_call+0x34/0x78
> [  106.486888] [<ffff20000824db0c>] do_idle+0x21c/0x3c0
> [  106.491856] [<ffff20000824e37c>] cpu_startup_entry+0x24/0x28
> [  106.497517] [<ffff200009fe9824>] rest_init+0x1ec/0x200
> [  106.502659] [<ffff20000a8117a0>] start_kernel+0x5d8/0x604
> [  106.508061] [<ffff20000a8101e8>] __primary_switched+0x6c/0x74
>
