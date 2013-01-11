From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v5 01/14] vlan: wrap hw-acceleration calls in
 separate functions.
Date: Fri, 11 Jan 2013 13:53:39 -0500
Message-ID: <50F05FB3.4000909@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com> <1357751882-8619-2-git-send-email-vyasevic@redhat.com> <20130110102525.2ff40c12@nehalam.linuxnetplumber.net> <50EF0B76.2040503@redhat.com> <20130110140749.153023fa@nehalam.linuxnetplumber.net> <50EF660B.2090500@redhat.com> <20130111092004.2d55ae65@nehalam.linuxnetplumber.net> <50F04EDC.9040309@redhat.com> <20130111102318.579abe94@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377Ab3AKSxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 13:53:45 -0500
In-Reply-To: <20130111102318.579abe94@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2013 01:23 PM, Stephen Hemminger wrote:
> On Fri, 11 Jan 2013 12:41:48 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> On 01/11/2013 12:20 PM, Stephen Hemminger wrote:
>>> What I think is the least intrusive and allows for maximum flexibility
>>> is having the VLAN bridge filtering depend on VLAN support (CONFIG_VLAN_8021Q).
>>> There already is drivers that depend on that value to enable filtering.
>>>
>>
>> The only thing that I see depending on CONFIG_VLAN_8021Q is
>> CONFIG_VLAN_8021Q_GVRP which is part of the 8021Q support.
>> There are currently no other drivers depending on 8021Q functionality
>> and vlan filtering in drivers doesn't depend on 8021Q support in
>> the kernel.
>>
>> I admit that I've thought of having a dependency on 8021Q as it would
>> have allowed me to re-use a bit more code, but decided that bridge
>> should be able to stand on its own in this regard.  8021Q is not
>> necessary to turn on VLAN accelerated filtering on the nics as anyone
>> can do it through the ndo_vlan_rx_add_vid() call.
>>
>> The reason for this patch was to make the nic vlan filter code reusable
>> and address Jiri Pirko's comment in the V2 series.
>> (http://marc.info/?l=linux-netdev&m=135590565719164&w=2).  This way,
>> bridge wouldn't need to make direct ndo_ calls and all call sights will
>> be consistent.
>>
>>> And make the support of VLAN filtering in the bridge conditional like
>>> IGMP snooping is optional
>>
>> I could certainly make the VLAN filtering conditional, but I am not sure
>> what it would buy us other then a lot of ifdefs.
>>
>> Thanks
>> -vlad
>>
>>>
>>> --- a/net/bridge/Kconfig
>>> +++ b/net/bridge/Kconfig
>>> @@ -46,3 +46,17 @@ config BRIDGE_IGMP_SNOOPING
>>>             Say N to exclude this support and reduce the binary size.
>>>
>>>             If unsure, say Y.
>>> +
>>> +config BRIDGE_VLAN_FILTERING
>>> +       bool "VLAN filtering"
>>> +       depends on BRIDGE
>>> +       depends on VLAN_8021Q
>>> +       default n
>>> +       ---help---
>>> +         If you say Y here, then the Ethernet bridge will be able to
>>> +        selectively filter traffic based on VLAN tag.
>>> +
>>> +        Say N to exclude this support and reduce the binary size.
>>> +
>>> +        If unsure, say Y.
>>>
>>
>
> Doing the following shows several drivers that still depend on VLAN_8021Q being
> enabled to do VLAN tagging.
> $ git grep -l CONFIG_VLAN_8021Q
> ethernet/3com/3c59x.c
> ethernet/adaptec/starfire.c
> ethernet/amd/amd8111e.c
> ethernet/broadcom/cnic.c
> ethernet/broadcom/tg3.c
> ethernet/dlink/sundance.c
> ethernet/natsemi/ns83820.c
> ethernet/sis/sis900.c
> ethernet/sis/sis900.h
> ethernet/stmicro/stmmac/common.h


OK.  You've convinced me.  I can make my code depend on 8021Q and move 
these functions into vlan module.
I'll update the series with these changes.

-vlad
