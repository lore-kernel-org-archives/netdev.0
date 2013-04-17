From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Wed, 17 Apr 2013 18:14:48 +0300
Message-ID: <516EBC68.1090802@mellanox.com>
References: <51360D7C.3060209@mellanox.com> <CACVXFVM2MLR6HxYyvKRnqddqvRbHvzL59+_NxqFek7YN7nDhQQ@mail.gmail.com> <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com> <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Don Dutile <ddutile@redhat.com>, Tejun Heo <tj@kernel.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:32928 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966603Ab3DQPPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:15:08 -0400
In-Reply-To: <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2013 04:03, Ming Lei wrote:
> On Thu, Mar 7, 2013 at 4:54 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Wed, Mar 6, 2013 at 4:43 AM, Ming Lei <ming.lei@canonical.com> wrote:
>>> You are adding one new PCI device inside another PCI device's probe(),
>>> so the new device will be probed, since PCI probe() is scheduled by
>>> work_on_cpu, then cause flush_work() called inside worker function,
>>> which might be a real deadlock.
>> So if I understand correct, you recommend to somehow avoid this nested probing?
> Yes, you might need to avoid the nested probing in your driver.
>
>>> I am wondering why this commit can cause the problem, since the PCI
>>> device will be probed with its driver if there is one driver for it. There is no
>>> any limit on when the driver should be loaded into system, either before
>>> device is added or after.
>> FWIW to undertstanding the issue - the same driver (mlx4_core) is used
>> by the PF and VF, so the VF driver is already loaded at the time its
>> been added as new PCI device.
>>
>>>  From driver core view, looks no wrong things are found.
>> So this got me confused, you pointed on possible deadlock, are you
>> saying the deadlock wouldn't be the result of how the driver code is
>> going nor the commited we bisected?
> My commit only affects the driver loading path, but your warning
> is hit in driver probe path triggered by device addition, so the lockdep
> warning should still be triggered without my commit since the two paths
> are totally independent, right?

If this is the case, I am not sure how come we never saw this warning 
before 3.9-rc1 which introduced your commit 
190888ac01d059e38ffe77a2291d44cafa9016fb "driver core: fix possible 
missing of device probe", any rough guess?
