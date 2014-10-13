From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 13 Oct 2014 11:06:12 -0700
Message-ID: <543C1494.4090602@candelatech.com>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com> <20140208172310.GF16198@order.stressinduktion.org> <loom.20140926T001736-777@post.gmane.org> <1411906297.2400343.172598909.66223582@webmail.messagingengine.com> <loom.20140929T195637-887@post.gmane.org> <5429A886.1040809@candelatech.com> <1412017399.14757.4.camel@localhost> <5429B783.20207@candelatech.com> <CAHA+R7O_xghD4a5RD=omhnuMD72pRmKU9VMoxPUVuGcu682jBg@mail.gmail.com> <5429CE26.6000108@candelatech.com> <CAGCdqXHh6AvabW2JwQEK5NcnTuxw9eMdRwd+JvYZUYqyHW4K7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hongmei Li <duckcncn@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:47180 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945AbaJMSGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 14:06:13 -0400
In-Reply-To: <CAGCdqXHh6AvabW2JwQEK5NcnTuxw9eMdRwd+JvYZUYqyHW4K7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2014 04:42 AM, Vladislav Yasevich wrote:
> On Mon, Sep 29, 2014 at 5:24 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 09/29/2014 01:39 PM, Cong Wang wrote:
>>> On Mon, Sep 29, 2014 at 12:48 PM, Ben Greear <greearb@candelatech.com> wrote:
>>>>
>>>> We are going to be running up to 20 concurrent scripts that
>>>> will be dumping routes & ips, and configuring ip addresses
>>>> and routes during bringup.
>>>>
>>>> I don't have a simple stand-alone way to reproduce this,
>>>> but at least when we reported the problem is was very easy
>>>> for us to reproduce with our tool.
>>>>
>>>> Maybe 20 scripts running in parallel that randomly configured and dumped routes
>>>> and ip addresses on random interfaces would do the trick?
>>>>
>>>
>>> I think the most important question is why is this related with macvlan?
>>> IPv6 is L3 while macvlan pure L2, if this is a IPv6 routing bug, it should
>>> not be limited to macvlan.
>>
>> We saw it using mac-vlans on top of ixgbe.  Probably it can be reproduced
>> elsewhere, but since we had a good test case, we didn't bother trying lots
>> of other combinations.
>>
>> Just enabling some debug code caused the problem to be much harder
>> to reproduce, so it is probably some sort of race.  Maybe lots of mac-vlans
>> make it easier to hit.
>>
>>> What does your IPv6 routing table look like? And how do you configure those
>>> macvlan interfaces?
>>
>> Each interface would have it's own routing table, with at least as subnet
>> route.  I'm not sure we were adding a default gateway or not.
>>
>> The main routing table would also have some auto-created routes
>> I think.
>>
>> It is configured using 'ip' to add and dump routes.
>>
> 
> Ben
> 
> Just saw this thread.  Can you check if this commit makes a difference:
> commit 40b8fe45d1f094e3babe7b2dc2b71557ab71401d
> Author: Vlad Yasevich <vyasevich@gmail.com>
> Date:   Mon Sep 22 16:34:17 2014 -0400
> 
>     macvtap: Fix race between device delete and open.

We can retest this, but we do not use macvtap, and we have higher-priority
things to test at the moment, so might be a while.

Thanks,
Ben

> 
> Thanks
> -vlad
> 
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear <greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
