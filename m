From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] phy: fix the bug when remove the phy driver
Date: Wed, 3 Aug 2016 12:22:53 +0800
Message-ID: <57A1719D.7000709@huawei.com>
References: <57A09988.9040702@huawei.com>
 <82f1f3de-0569-2346-9a69-fcfd5d49c565@gmail.com>
 <57A14730.6070309@huawei.com>
 <8A86BAAA-7D4C-41BC-A65C-3D618208B5C2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18527 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbcHCEcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 00:32:54 -0400
In-Reply-To: <8A86BAAA-7D4C-41BC-A65C-3D618208B5C2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/8/3 10:41, Florian Fainelli wrote:
> On August 2, 2016 6:21:52 PM MST, Ding Tianhong <dingtianhong@huawei.com> wrote:
>> On 2016/8/3 0:42, Florian Fainelli wrote:
>>> Le 02/08/2016 à 06:00, Ding Tianhong a écrit :
>>>> The nic in my board use the phy dev from marvell, and
>>>> the system will load the marvell phy driver automatically,
>>>> but when I remove the phy drivers, the system immediately panic:
>>>>
>>>> localhost login: [ 2582.052465] Unable to handle kernel NULL pointer
>> dereference at virtual address 000000c0
>>>> [ 2582.061429] pgd = ffff800001226000
>>>> [ 2582.065277] [000000c0] *pgd=0000003f7f893003,
>> *pud=0000003f7f894003, *pmd=0000003f7f895003, *pte=006000006d000707
>>>> [ 2582.076681] Internal error: Oops: 96000006 [#1] SMP
>>>> [ 2582.082049] Modules linked in: sr_mod(E) cdrom(E) ses(E)
>> enclosure(E) shpchp(E) crc32_arm64(E) aes_ce_blk(E) ablk_helper(E)
>> cryptd(E) aes_ce_cipher(E) ghash_ce(E) sha2_ce(E) sha1_ce(E)
>> usb_storage(E) dm_mirror(E) dm_region_hash(E) dm_log(E) dm_mod(E) [last
>> unloaded: marvell]
>>>> [ 2582.109226] CPU: 21 PID: 1514 Comm: kworker/21:1 Tainted: G      
>>     E   4.1.27-vhulk3.6.5.aarch64 #1
>>>> [ 2582.119415] Hardware name: Huawei Taishan 2180 /BC11SPCC, BIOS
>> 1.31 06/23/2016
>>>> [ 2582.127346] Workqueue: events_power_efficient phy_state_machine
>>>> [ 2582.133796] task: ffff803f6f41bac0 ti: ffff803f6eca4000 task.ti:
>> ffff803f6eca4000
>>>> [ 2582.141910] PC is at phy_state_machine+0x3c/0x438
>>>> [ 2582.147081] LR is at phy_state_machine+0x34/0x438
>>>> [ 2582.152173] pc : [<ffff800000715384>] lr : [<ffff80000071537c>]
>> pstate: 60000145
>>>> [ 2582.160189] sp : ffff803f6eca7d30
>>>> [ 2582.163825] x29: ffff803f6eca7d30 x28: 0000000000000000
>>>> [ 2582.169689] x27: ffff805fdfd0aa00 x26: 0000000000000008
>>>> [ 2582.175482] x25: 0000000000000000 x24: ffff80000112c57c
>>>> [ 2582.181391] x23: ffff805f4fc8a800 x22: ffff805fdfd0f700
>>>> [ 2582.187241] x21: ffff805f4fc8abf8 x20: ffff805f4fc8a770
>>>> [ 2582.193035] x19: ffff805f4fc8ab70 x18: 0000000000000007
>>>> [ 2582.198914] x17: 000000000000000e x16: 0000000000000001
>>>> [ 2582.204710] x15: 0000000000000007 x14: 000000000000000e
>>>> [ 2582.210584] x13: 0000000000000200 x12: 0000000055555556
>>>> [ 2582.216373] x11: 0000000000001c00 x10: 0000000000000000
>>>> [ 2582.222166] x9 : ffff800000a36880 x8 : ffff803f6f41c060
>>>> [ 2582.227994] x7 : 000000010008b39b x6 : ffff80000101e690
>>>> [ 2582.233788] x5 : 0000000000000000 x4 : 0000000000800000
>>>> [ 2582.239612] x3 : 0000000000000000 x2 : 0000000000000000
>>>> [ 2582.245404] x1 : 0000000000000000 x0 : 0000000000000000
>>>> [ 2582.265813]
>>>> [ 2582.282971] Process kworker/21:1 (pid: 1514, stack limit =
>> 0xffff803f6eca4020)
>>>> [ 2582.307284] Stack: (0xffff803f6eca7d30 to 0xffff803f6eca8000)
>>>> [ 2582.331183] 7d20:                                  
>> ffff803f6eca7d70 ffff8000000db3b8
>>>> [ 2582.354788] 7d40: ffff803f6e696000 ffff805f4fc8ab70
>> ffff805fdfd0aa00 ffff805fdfd0f700
>>>> [ 2582.378341] 7d60: 0000000000000000 ffff80000112c57c
>> ffff803f6eca7dc0 ffff8000000db7d4
>>>> [ 2582.403700] 7d80: ffff803f6e696000 ffff803f6e696030
>> ffff805fdfd0aa18 ffff805fdfd0aa00
>>>> [ 2582.428385] 7da0: ffff803f6eca4000 ffff80000112c57c
>> 0000000000000000 0000000000000008
>>>> [ 2582.451222] 7dc0: ffff803f6eca7e20 ffff8000000e1d0c
>> ffff805f4fc15000 ffff80000115f188
>>>> [ 2582.474577] 7de0: ffff800000d1cf88 ffff803f6e696000
>> ffff8000000db690 0000000000000000
>>>> [ 2582.497281] 7e00: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.522992] 7e20: 0000000000000000 ffff800000083dd0
>> ffff8000000e1c10 ffff805f4fc15000
>>>> [ 2582.546945] 7e40: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.568550] 7e60: 0000000000000000 ffff8000000ee33c
>> ffff803f6e696000 ffff805f00000000
>>>> [ 2582.589157] 7e80: 0000000000000000 ffff803f6eca7e88
>> ffff803f6eca7e88 0000000000000000
>>>> [ 2582.609767] 7ea0: 0000000000000000 ffff803f6eca7ea8
>> ffff803f6eca7ea8 cb88537fdc8ba31b
>>>> [ 2582.633228] 7ec0: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.655386] 7ee0: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.674223] 7f00: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.692994] 7f20: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.711765] 7f40: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.730809] 7f60: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.748601] 7f80: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.769388] 7fa0: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.786756] 7fc0: 0000000000000000 0000000000000005
>> 0000000000000000 0000000000000000
>>>> [ 2582.804134] 7fe0: 0000000000000000 0000000000000000
>> 0000000000000000 0000000000000000
>>>> [ 2582.821488] Call trace:
>>>> [ 2582.834493] [<ffff800000715384>] phy_state_machine+0x3c/0x438
>>>> [ 2582.851754] [<ffff8000000db3b8>] process_one_work+0x150/0x428
>>>> [ 2582.868188] [<ffff8000000db7d4>] worker_thread+0x144/0x4b0
>>>> [ 2582.883882] [<ffff8000000e1d0c>] kthread+0xfc/0x110
>>>>
>>>> ============================cut here===============================
>>>>
>>>> The phy_state_machine was still running and didn't know whether the
>> phydev's driver was
>>>> removed or not, then occur this problem, so we need to stop the
>> phy_state_machine when
>>>> removing the phy driver.
>>>
>>> Your explanation of the problem is unclear to me, unless a network
>>> driver attached to the PHY and started it, and then never stopped the
>>> PHY state machine, this should not happen, also there should be
>> proper
>>> reference counting in place to avoid that. Your trace is based on 4.1
>> is
>>> this still reproducible with latest vanilla? Is this with a mainline
>>> Ethernet driver?
>>>
>>
>> Yes，the network driver already attached to the PHY and started it, and
>> all
>> of them could work well if I didn't do anything, but if I suddenly
>> remove the marvall.ko,
>> the phy_state_machine was still running, but the phydev->drv is NULL at
>> this time, than oops,
>> I found this problem at 4.1 lts, and didn't see any effective
>> improvement in the kernel 4.8, so
>> report this bug and fix it.
> 
> Ok, then the issue seems to be with reference counting here, we should not be able to unload
>the module until the last user dropped the reference, which would be when the Ethernet driver 
>called phy_disconnect(). Your fix does not prevent a dangling phy_device pointer from being 
>accessed in the Ethernet driver for instance because the PHY would be silently dropped.
> 

I couldn't stop the root or other user to do the stupid action just like unload a drivers, but we need to make sure
the system could still work and avoid the more serious consequences, and I think the phy_remove has done a lot of
things for unloading action, but still miss to stop the phy_state_machine.

Maybe you could give me more suggestion how to fix this problem, thanks very much for any opinion.

Ding 
