From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Thu, 6 Apr 2017 19:28:30 +0800
Message-ID: <47a6333d-a853-5a40-e668-efe6f7b5c5b2@huawei.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
 <1491031554-19516-2-git-send-email-dingtianhong@huawei.com>
 <20170401.112603.1991545644693496714.davem@davemloft.net>
 <819bc6c1-581b-3ab9-d189-1befaaf43548@huawei.com>
 <118dee30-69a8-4ee0-791d-a46d268af3b4@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
        <mark.rutland@arm.com>, <robin.murphy@arm.com>,
        <jeffrey.t.kirsher@intel.com>, <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <intel-wired-lan@lists.osuosl.org>, LinuxArm <linuxarm@huawei.com>
To: John Garry <john.garry@huawei.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5342 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753861AbdDFL3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 07:29:12 -0400
In-Reply-To: <118dee30-69a8-4ee0-791d-a46d268af3b4@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2017/4/5 21:05, John Garry wrote:
> On 02/04/2017 07:49, Ding Tianhong wrote:
>>
>>
>> On 2017/4/2 2:26, David Miller wrote:
>>> From: Ding Tianhong <dingtianhong@huawei.com>
>>> Date: Sat, 1 Apr 2017 15:25:51 +0800
>>>
>>>> Till now only the Intel ixgbe could support enable
>>>> Relaxed ordering in the drivers for special architecture,
>>>> but the ARCH_WANT_RELAX_ORDER is looks like a general name
>>>> for all arch, so rename to a specific name for intel
>>>> card looks more appropriate.
>>>>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>
>>> This is not a driver specific facility.
>>>
>>> Any driver can test this symbol and act accordingly.
>>>
>>> Just because IXGBE is the first and only user, doesn't mean
>>> the facility is driver specific.
>>>
>>
>> Understand clearly，but the ARCH_WANT_RELAX_ORDER is really too generic and simple,
>> cause much misleading to indicate that it looks like the hack code for some architecture.
>> what do you think of the ETHERNET_ALLOW_RELAXED_ORDER in the drivers/net/ethernet/*,
>> it will only affect ethernet and not only for Ixgbe.
>>
> 

Hi John:

> Hi Ding,
> 
> I think the actual original config ARCH_WANT_RELAX_ORDER is quite dubious, and it does not really tell us which feature(s) of the architecture supports this (if indeed it is arch specific).
> 

Agree.

> According to the original commit, 1a8b6d76dc5b net:add one common config ARCH_WANT_RELAX_ORDER to support relax ordering, this is specific to SPARC only:
> "Currently it only supports one special cpu architecture(SPARC) in 82599 driver to enable RO feature, this is not very common for other cpu architecture which really needs RO feature".
> 

Relaxed Ordering is a general setting compare to the SO for PCIE controller, if the drivers support it, the architecture could choose to enable it, of course the feature is not support for
every arch.

> This sounds wooly.
> 
> So I think that we need to know which specific architecture, memory model, or PCI host/port/EP features, or combination of them, allows this so called relaxed ordering.
> 

This depends on the PCIE design in the chip, I couldn't know whether other arch has some issues when enable RO，if the chip totally support PCIE3.0 standard and has no defect,should both support RO and SO.

Thanks
Ding
> And a config option is probably not even the proper check.
> 
> John





> 
>> Thanks
>> Ding
>>
>>
>>> Thank you.
>>>
>>> .
>>>
>>
>>
>> .
>>
> 
> 
> 
> .
> 
