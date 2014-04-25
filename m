From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Fri, 25 Apr 2014 18:23:58 +0800
Message-ID: <535A37BE.7020203@huawei.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com> <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com> <5357280C.1000404@huawei.com> <53576A6F.2020207@6wind.com> <53586207.7060407@huawei.com> <20140424054734.GA16057@unicorn.suse.cz> <5358F649.6090206@huawei.com> <5359066D.2010206@huawei.com> <53590FC9.6090607@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <kaber@trash.net>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>, Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29991 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaDYKYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 06:24:49 -0400
In-Reply-To: <53590FC9.6090607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/4/24 21:21, Nicolas Dichtel wrote:
> Le 24/04/2014 14:41, chenweilong a =E9crit :
>> On 2014/4/24 19:32, chenweilong wrote:
>>> On 2014/4/24 13:47, Michal Kubecek wrote:
>>>> On Thu, Apr 24, 2014 at 08:59:51AM +0800, chenweilong wrote:
>>>>> On 2014/4/23 15:23, Nicolas Dichtel wrote:
>>>>>> Le 23/04/2014 04:40, chenweilong a =E9crit :
>>>>>>> And, 2) is not safe, if someone forgets to move eth1, eth1.5 wi=
ll not work, making
>>>>>>> things complex.
>>>>>> We have to fix this case, because it is a valid use case to have=
 eth1.5 in net0
>>>>>> and eth1 in another ns.
>>>>>>
>>>>> eth1.5 can receive and send packets in net0, the problem is you c=
an't add a new eth1.5
>>>>> in old ns, report 'error: File exists'.
>>>>
>>>> And this is correct, as far as I can tell. If it was possible, whi=
ch of
>>>> the two interfaces would receive VLAN tagged packets with VID 5 co=
ming
>>>> to eth1?
>>>>
>>>>                                                           Michal K=
ubecek
>>>>
>>>>
>>>>
>>> If eth1 and eth1.5 can work in different ns,
>>> my fist test(move eth1 first,and then eth1.5) should be success,
>>> but it failed, if eth1 was moved to other ns, all related vlans wer=
e unregisted.
>>> Strangely, if I move eth1.5 to net0, then move eth1 to net0, and th=
en
>>> move eth1 to net1, eth1.5 is still there!
>>> It is a bug?
>> Find at last it's a behavior of SUSE's udevd , not the kernel.
>> When move eth1 to net0, udevd call /sbin/ifdown to down eth1
>> and then ifdown eth1.5, and then ifdown-802.1q eth1.5 and then
>> vconfig rem eth1.5!
>>
>> Thanks everybody!
>>>
>>> I agree with you there should be one interface tagged with VID 5 in=
 the system.
>>> But I think the network namespaces are independent, vlan port and i=
ts VID interfaces
>>> spread in different ns break the rule.
> VID are unique per interface, for example eth0 can only have one VID =
5.
> Even if eth1.5 stands in another netns, it is still "connected" to et=
h0.
>=20
> I agree that network namespaces are independent, but there are mechan=
ism to
> connect them between each other or to connect these netns to a "physi=
cal"
> network even if you don't have a NIC for each netns on your system. F=
or
> example, IP tunnels (ipip, sit, ip6_tunnels) allow to have encapsulat=
ion
> addresses in one netns and the netdevice in another netns:
>=20
> ip netns add ns1
> ip netns exec ns1 ip link set lo up
>=20
> ip link add ipip1 type ipip remote 10.16.0.121 local 10.16.0.249
> ip link set ipip1 netns ns1
> ip netns exec ns1 ip link set ipip1 up
> ip netns exec ns1 ip addr add dev ipip1 192.168.2.123 remote 192.168.=
2.121
>=20
> vlan may also provide this kind of mechanism.
>=20
> Regards,
> Nicolas
>=20
>=20
Agree,

Thanks!
