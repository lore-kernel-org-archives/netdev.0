From: Dan Geist <dan@polter.net>
Subject: Re: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Fri, 3 Mar 2017 11:22:13 -0500 (EST)
Message-ID: <91762243.3454.1488558132852.JavaMail.zimbra@polter.net>
References: <20170302103219.74b675c5@xeon-e3> <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com> <1601587594.2278.1488487199506.JavaMail.zimbra@polter.net> <4bd4e7b9-5546-2e85-bb08-42e45a13e1f3@6wind.com> <20170303160348.GA1888@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong <chenweilong@huawei.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from schnell.polter.net ([99.33.109.108]:50824 "EHLO
        schnell.polter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdCCQuB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 11:50:01 -0500
In-Reply-To: <20170303160348.GA1888@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Mar 3, 2017, at 11:03 AM, Jiri Pirko jiri@resnulli.us wrote:

> Fri, Mar 03, 2017 at 04:19:13PM CET, nicolas.dichtel@6wind.com wrote:
>>Le 02/03/2017 à 21:39, Dan Geist a écrit :
>>> ----- On Mar 2, 2017, at 3:11 PM, Cong Wang xiyou.wangcong@gmail.com wrote
>>> 
>>>> On Thu, Mar 2, 2017 at 10:32 AM, Stephen Hemminger
>>>> <stephen@networkplumber.org> wrote:
>>>>>
>>>>>
>>>>> Begin forwarded message:
>>>>>
>>>>> Date: Wed, 01 Mar 2017 21:08:01 +0000
>>>>> From: bugzilla-daemon@bugzilla.kernel.org
>>>>> To: stephen@networkplumber.org
>>>>> Subject: [Bug 194749] New: kernel bonding does not work in a network nameservice
>>>>> in versions above 3.10.0-229.20.1
>>>>
>>>>>
>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=194749
>>>>>
>>>>>             Bug ID: 194749
>>>>>            Summary: kernel bonding does not work in a network nameservice
>>>>>                     in versions above 3.10.0-229.20.1
>>>>>            Product: Networking
>>>>>            Version: 2.5
>>>>>     Kernel Version: > 3.10.0-229.20.1
>>>>>           Hardware: x86-64
>>>>>                 OS: Linux
>>>>>               Tree: Mainline
>>>>>             Status: NEW
>>>>>           Severity: blocking
>>>>>           Priority: P1
>>>>>          Component: Other
>>>>>           Assignee: stephen@networkplumber.org
>>>>>           Reporter: dan@polter.net
>>>>>         Regression: No
>>>>>
>>>>> bond interface is being used in active/standby mode with two physical NICs
>>>>> inside a network nameservice to provide switchpath redundancy.
>>>>>
>>>>> netns is instantiated post-boot with the following:
>>>>>
>>>>> ip netns add vntp
>>>>> ip link set p4p1 netns vntp
>>>>> ip link set p4p2 netns vntp
>>>>> ip link set bond0 netns vntp
>>>>> ip netns exec vntp ip link set lo up
>>>>> ip netns exec vntp ip link set p4p1 up
>>>>> ip netns exec vntp ip link set p4p2 up
>>>>> ip netns exec vntp ip link set bond0 up
>>>>> ip netns exec vntp ifenslave bond0 p4p1 p4p2
>>>>
>>>> This is due to the following commit:
>>>>
>>>> commit f9399814927ad9bb995a6e109c2a5f9d8a848209
>>>> Author: Weilong Chen <chenweilong@huawei.com>
>>>> Date:   Wed Jan 22 17:16:30 2014 +0800
>>>>
>>>>    bonding: Don't allow bond devices to change network namespaces.
>>>>
>>>>    Like bridge, bonding as netdevice doesn't cross netns boundaries.
>>>>
>>>>    Bonding ports and bonding itself live in same netns.
>>>>
>>>>    Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>>>>    Signed-off-by: David S. Miller <davem@davemloft.net>
>>>>
>>>>
>>>> NETIF_F_NETNS_LOCAL was introduced for loopback device which
>>>> is created for each netns, it is not clear why we need to add it to bond
>>>> and bridge...
>>> 
>>> Thank you for tracking this down. Without digging through the code to figure it
>>> out, does this imply that the existence of a bond interface is not possible AT
>>> ALL within a netns or simply that it may not be "migrated" between the global
>>> scope and a netns?
>>It means that the migration is not possible. I think the only reason to have
>>this flag on bonding and bridge is the lack of test and fix. There is probably
>>some work to be done to have this feature. But are there real use cases of
>>x-netns bonding or x-netns bridge?
> 
> If that use case exists I believe it is an abuse. Soft devices that are
> by definition in upper-lower relationships with other devices should not
> move to other namespaces. Prevents all kinds of issues. If you need a
> soft device like bridge of bond within a namespace, just create it there.

I think the implementation is good as it stands and i don't have a use case to the contrary. I simply misunderstood the implications of creating the bond interface in the global space and had been utilizing the unnecessarily permissive behavior of the older kernels. Once I stopped doing that and migrated the instance creation to within the netns, my desired behavior and functionality were restored. I also commented the bug report on vger as such.

Thanks for the clarification and consideration.
Dan 

-- 
Dan Geist dan(@)polter.net
