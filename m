From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Wed, 23 Apr 2014 09:23:27 +0200
Message-ID: <53576A6F.2020207@6wind.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com> <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com> <5357280C.1000404@huawei.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:59046 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbaDWHXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 03:23:30 -0400
Received: by mail-wi0-f182.google.com with SMTP id d1so661487wiv.9
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 00:23:29 -0700 (PDT)
In-Reply-To: <5357280C.1000404@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/04/2014 04:40, chenweilong a =C3=A9crit :
> On 2014/4/22 22:26, Eric Dumazet wrote:
>> On Tue, 2014-04-22 at 20:43 +0800, Chen Weilong wrote:
>>> From: Weilong Chen <chenweilong@huawei.com>
>>>
>>> Like bonding, vlan as netdevice doesn't cross netns boundaries.
>>>
>>> Vlan port and vlan itself live in same netns.
>>
>> Please explain why you believe it should be like that.
>>
>> bonding and vlan have quite different purpose, so your changelog is
>> quite obscure.
>>
>> We had a discussion like this one with macvlan, and prior patch was
>> rejected.
>>
>>
>>
>>
> This idea comes from the different result of two changing namespace o=
rders.
> Test on eth1 and its vlan eth1.5, move them form default ns to a new =
ns called net0.
> 1.move eth1 first,and then eth1.5;
> 2.move eth1.5 first, and then eth1;
> As a network manager, I will be happy they both work, I don't care ab=
out the orders.
> But, 1) doesn't work, if eth1 was moved to other ns, all related vlan=
s were unregisted.
> you need to create a new eth1.5 in net0.
> And, 2) is not safe, if someone forgets to move eth1, eth1.5 will not=
 work, making
> things complex.
We have to fix this case, because it is a valid use case to have eth1.5=
 in net0
and eth1 in another ns.

>
> So what's the better order ?
> I prefer 1), when a vlan dev is setup, it has a namespace, and belong=
s to it,
> When somebody moves it, it should say 'hey boy, don't move me,I like =
here :0'
>
> Thanks,
> Weilong
