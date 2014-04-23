From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Wed, 23 Apr 2014 10:40:12 +0800
Message-ID: <5357280C.1000404@huawei.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com> <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:31724 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaDWCke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 22:40:34 -0400
In-Reply-To: <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/4/22 22:26, Eric Dumazet wrote:
> On Tue, 2014-04-22 at 20:43 +0800, Chen Weilong wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
>>
>> Like bonding, vlan as netdevice doesn't cross netns boundaries.
>>
>> Vlan port and vlan itself live in same netns.
> 
> Please explain why you believe it should be like that.
> 
> bonding and vlan have quite different purpose, so your changelog is
> quite obscure.
> 
> We had a discussion like this one with macvlan, and prior patch was
> rejected.
> 
> 
> 
> 
This idea comes from the different result of two changing namespace orders.
Test on eth1 and its vlan eth1.5, move them form default ns to a new ns called net0.
1.move eth1 first,and then eth1.5;
2.move eth1.5 first, and then eth1;
As a network manager, I will be happy they both work, I don't care about the orders.
But, 1) doesn't work, if eth1 was moved to other ns, all related vlans were unregisted.
you need to create a new eth1.5 in net0.
And, 2) is not safe, if someone forgets to move eth1, eth1.5 will not work, making
things complex.

So what's the better order ?
I prefer 1), when a vlan dev is setup, it has a namespace, and belongs to it,
When somebody moves it, it should say 'hey boy, don't move me,I like here :0'

Thanks,
Weilong
