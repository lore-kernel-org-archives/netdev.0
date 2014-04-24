From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Thu, 24 Apr 2014 19:32:25 +0800
Message-ID: <5358F649.6090206@huawei.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com> <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com> <5357280C.1000404@huawei.com> <53576A6F.2020207@6wind.com> <53586207.7060407@huawei.com> <20140424054734.GA16057@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.dichtel@6wind.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	<kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:7444 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473AbaDXLeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 07:34:02 -0400
In-Reply-To: <20140424054734.GA16057@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/4/24 13:47, Michal Kubecek wrote:
> On Thu, Apr 24, 2014 at 08:59:51AM +0800, chenweilong wrote:
>> On 2014/4/23 15:23, Nicolas Dichtel wrote:
>>> Le 23/04/2014 04:40, chenweilong a =E9crit :
>>>> And, 2) is not safe, if someone forgets to move eth1, eth1.5 will =
not work, making
>>>> things complex.
>>> We have to fix this case, because it is a valid use case to have et=
h1.5 in net0
>>> and eth1 in another ns.
>>>
>> eth1.5 can receive and send packets in net0, the problem is you can'=
t add a new eth1.5
>> in old ns, report 'error: File exists'.
>=20
> And this is correct, as far as I can tell. If it was possible, which =
of
> the two interfaces would receive VLAN tagged packets with VID 5 comin=
g
> to eth1?
>=20
>                                                          Michal Kubec=
ek
>=20
>=20
>=20
If eth1 and eth1.5 can work in different ns,
my fist test(move eth1 first,and then eth1.5) should be success,
but it failed, if eth1 was moved to other ns, all related vlans were un=
registed.
Strangely, if I move eth1.5 to net0, then move eth1 to net0, and then
move eth1 to net1, eth1.5 is still there!
It is a bug?

I agree with you there should be one interface tagged with VID 5 in the=
 system.
But I think the network namespaces are independent, vlan port and its V=
ID interfaces
spread in different ns break the rule.

Thanks,
