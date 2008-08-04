From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: 2.6.27-rc1-git4 BUG: sched while atomic
Date: Mon, 04 Aug 2008 16:13:14 -0300
Message-ID: <489754CA.4020705@linux.vnet.ibm.com>
References: <20080804094835.da083484.randy.dunlap@oracle.com> <20080804101712.659780ef@extreme> <1217859640.6746.2.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw1.br.ibm.com ([32.104.18.24]:46925 "EHLO igw1.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757528AbYHDTWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 15:22:00 -0400
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw1.br.ibm.com (Postfix) with ESMTP id 8F24132C1EC
	for <netdev@vger.kernel.org>; Mon,  4 Aug 2008 15:53:30 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m74JDOD83350594
	for <netdev@vger.kernel.org>; Mon, 4 Aug 2008 16:13:24 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m74JDH7u015472
	for <netdev@vger.kernel.org>; Mon, 4 Aug 2008 16:13:17 -0300
In-Reply-To: <1217859640.6746.2.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> On Mon, 2008-08-04 at 10:17 -0700, Stephen Hemminger wrote:
>>> In 2.6.27-rc1-git4, I now see this (39 times):
>>>
>>> BUG: scheduling while atomic: ifconfig/16971/0x00000100
>>> Modules linked in: parport_pc lp parport tg3 lpfc cciss ehci_hcd
>> ohci_hcd uhci_hcd
>>> Pid: 16971, comm: ifconfig Not tainted 2.6.27-rc1-git4 #1
>>>
>>> Call Trace:
>>>  [<ffffffff80283db9>] ? page_add_new_anon_rmap+0x20/0x22
>>>  [<ffffffff802310e9>] __schedule_bug+0x62/0x66
>>>  [<ffffffff80551146>] schedule+0x99/0x759
>>>  [<ffffffff8023dc9f>] ? __mod_timer+0xc1/0xd3
>>>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>>>  [<ffffffff80551ce4>] schedule_timeout+0x8d/0xb4
>>>  [<ffffffff8023d99e>] ? process_timeout+0x0/0xb
>>>  [<ffffffff80551cdf>] ? schedule_timeout+0x88/0xb4
>>>  [<ffffffff80551d24>] schedule_timeout_uninterruptible+0x19/0x1b
>>>  [<ffffffff8023dcc5>] msleep+0x14/0x1e
>>>  [<ffffffff80375f2f>] pci_set_power_state+0x1cd/0x292
>>>  [<ffffffff803739fc>] ? pci_bus_write_config_dword+0x64/0x73
>>>  [<ffffffffa00651b6>] tg3_set_power_state+0x58/0x884 [tg3]
>>>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>>>  [<ffffffffa006b57a>] tg3_open+0x46/0x6cc [tg3]
>>>  [<ffffffff80552525>] ? __mutex_lock_slowpath+0x1d8/0x1e5
>>>  [<ffffffff804bdcfe>] dev_open+0x73/0xa8
>>>  [<ffffffff804bbf5e>] dev_change_flags+0xab/0x167
>>>  [<ffffffff804f7094>] devinet_ioctl+0x269/0x5da
>>>  [<ffffffff8026d9da>] ? unlock_page+0x2d/0x32
>>>  [<ffffffff804f7ca8>] inet_ioctl+0x92/0xaa
>>>  [<ffffffff804b2046>] sock_ioctl+0x1d1/0x1fb
>>>  [<ffffffff802a50aa>] vfs_ioctl+0x2a/0x77
>>>  [<ffffffff802a534c>] do_vfs_ioctl+0x255/0x272
>>>  [<ffffffff8055584a>] ? do_page_fault+0x473/0x7dd
>>>  [<ffffffff802a53ab>] sys_ioctl+0x42/0x67
>>>  [<ffffffff8020beeb>] system_call_fastpath+0x16/0x1b
>> This is a bug.
>>
> 
> This was introduced by:
> 
> tg3: adapt tg3 to use reworked PCI PM code
> 
> Adapt the tg3 driver to use the reworked PCI PM and make it use the
> exported PCI PM core functions instead of accessing the PCI PM registers
> directly by itself.

I just reverted this patch on my tree and the problem doesn't happen anymore.
