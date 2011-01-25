From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: does intel X520-SR(ixgbe) support RSS on single VLAN?
Date: Tue, 25 Jan 2011 13:34:57 -0800
Message-ID: <4D3F4201.30805@intel.com>
References: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>	<4D3DB248.5070802@intel.com>	<AANLkTimFuUp+wbgJY4koZ96st1eBbFqVOxOPj4tU_-Ao@mail.gmail.com>	<1295924734.2896.6.camel@localhost> <AANLkTik9bcRjJ4N7_rny_pf6qzR2RbUZRKtz5y9sW0Sb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59464 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112Ab1AYVe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 16:34:57 -0500
In-Reply-To: <AANLkTik9bcRjJ4N7_rny_pf6qzR2RbUZRKtz5y9sW0Sb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/25/2011 1:03 AM, Rui wrote:
> On Tue, Jan 25, 2011 at 11:05 AM, Ben Hutchings
> <bhutchings@solarflare.com>  wrote:
>> On Tue, 2011-01-25 at 10:10 +0800, Rui wrote:
>>> On Tue, Jan 25, 2011 at 1:09 AM, Alexander Duyck
>>> <alexander.h.duyck@intel.com>  wrote:
>>>> On 1/24/2011 6:18 AM, Rui wrote:
>>>>>
>>>>> hi
>>>>> does intel X520-SR support RSS on single VLAN?
>>>>>
>>>>> tested with 3 different vlan id and priority packets
>>>>> What I saw is that all packets were always delivered to the same =
RxQ.
>>>>> looks can not get a different RSS index for these packet?
>>>>> any setting needed?
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>>
>>>> The X520 should have no problems hashing on a single VLAN tagged f=
rame.
>>>>   However the VLAN will not be a part of the RSS hash.  The  only =
components
>>>> of the hash are the IPv4/IPv6 source and destination addresses, an=
d if the
>>>> flow is TCP then the port numbers.
>>>>
>>> hi alexander
>>> I got these information from the intel community:
>>>
>>> 'I asked our software engineers about your question, and this is wh=
at I learned.
>>> You cannot filter by just VLAN or VLAN priority.  The L4 type will
>>> also play a role in the filter and as such you would only be able t=
o
>>> filter TCP, UDP, and SCTP packets that are bound for a VLAN.
>>> The command itself to setup a filter is =93ethtool =96U ethX flow-t=
ype
>>> tcp4 vlan 0x2000 vlan-mask 0xE000 action Y=94 where X is the correc=
t
>>> index for the interface and Y is the queue you want to route the
>>> traffic to.  This would have to be repeated for udp4 and sctp4.
>>> I hope this will help.
>>> Mark H"
>>
>> The mask specifies bits to be ignored, so if you want to filter on t=
he
>> basis of only the priority bits you should use vlan-mask 0xfff.  Unl=
ess
>> this is another inconsistency I failed to notice...
>>
>>> so my question is that the VLAN is PART of the RSS or not?
>>
>> It's not part of any specified Toeplitz hash.  However, some hardwar=
e
>> supports adding the hash (after indirection) to the queue number
>> specified by a filter.  Currently the ethtool API doesn't have a way=
 to
>> request that.
>>
>>> looks the
>>> perfect filter support vlan id ?can the perfect filter support
>>> wildchar,such as: flow-type ANY?
>>
>> It is possible to specify this using flow-type ether, but the ixgbe
>> driver does not yet support that (and I have no idea whether the
>> hardware does).
>>
>> Ben.
>>
>> --
>> Ben Hutchings, Senior Software Engineer, Solarflare Communications
>> Not speaking for my employer; that's the marketing department's job.
>> They asked us to note that Solarflare product names are trademarked.
>>
>>
>
> I got this msg:
> Cannot add new RX n-tuple filter: Operation not supported
> This command is only supported after 2.6.34?

Yes, this command will only work on 2.6.34 and older kernels.

Thanks,

Alex
