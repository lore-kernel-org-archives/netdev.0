From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Thu, 24 Apr 2014 20:41:17 +0800
Message-ID: <5359066D.2010206@huawei.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com> <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com> <5357280C.1000404@huawei.com> <53576A6F.2020207@6wind.com> <53586207.7060407@huawei.com> <20140424054734.GA16057@unicorn.suse.cz> <5358F649.6090206@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.dichtel@6wind.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	<kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:39287 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368AbaDXMlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 08:41:52 -0400
In-Reply-To: <5358F649.6090206@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/4/24 19:32, chenweilong wrote:
> On 2014/4/24 13:47, Michal Kubecek wrote:
>> On Thu, Apr 24, 2014 at 08:59:51AM +0800, chenweilong wrote:
>>> On 2014/4/23 15:23, Nicolas Dichtel wrote:
>>>> Le 23/04/2014 04:40, chenweilong a =E9crit :
>>>>> And, 2) is not safe, if someone forgets to move eth1, eth1.5 will=
 not work, making
>>>>> things complex.
>>>> We have to fix this case, because it is a valid use case to have e=
th1.5 in net0
>>>> and eth1 in another ns.
>>>>
>>> eth1.5 can receive and send packets in net0, the problem is you can=
't add a new eth1.5
>>> in old ns, report 'error: File exists'.
>>
>> And this is correct, as far as I can tell. If it was possible, which=
 of
>> the two interfaces would receive VLAN tagged packets with VID 5 comi=
ng
>> to eth1?
>>
>>                                                          Michal Kube=
cek
>>
>>
>>
> If eth1 and eth1.5 can work in different ns,
> my fist test(move eth1 first,and then eth1.5) should be success,
> but it failed, if eth1 was moved to other ns, all related vlans were =
unregisted.
> Strangely, if I move eth1.5 to net0, then move eth1 to net0, and then
> move eth1 to net1, eth1.5 is still there!
> It is a bug?
=46ind at last it's a behavior of SUSE's udevd , not the kernel.
When move eth1 to net0, udevd call /sbin/ifdown to down eth1
and then ifdown eth1.5, and then ifdown-802.1q eth1.5 and then
vconfig rem eth1.5!

Thanks everybody!
>=20
> I agree with you there should be one interface tagged with VID 5 in t=
he system.
> But I think the network namespaces are independent, vlan port and its=
 VID interfaces
> spread in different ns break the rule.
>=20
> Thanks,
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
