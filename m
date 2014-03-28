From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next v3 2/2] net: tcp_ipv6 policy route issue
Date: Fri, 28 Mar 2014 09:11:37 +0800
Message-ID: <5334CC49.7030603@huawei.com>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com> <1395642322-9404-2-git-send-email-wangyufen@huawei.com> <20140326070548.GF22086@order.stressinduktion.org> <53338642.1060405@huawei.com> <20140327053231.GL22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:48938 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbaC1BLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 21:11:51 -0400
In-Reply-To: <20140327053231.GL22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/27 13:32, Hannes Frederic Sowa wrote:
> On Thu, Mar 27, 2014 at 10:00:34AM +0800, wangyufen wrote:
>> On 2014/3/26 15:05, Hannes Frederic Sowa wrote:
>>> On Mon, Mar 24, 2014 at 02:25:22PM +0800, Wangyufen wrote:
>>>> From: Wang Yufen <wangyufen@huawei.com>
>>>>
>>>> The issue raises when adding policy route, specify a particular
>>>> NIC as oif, the policy route did not take effect. The reason is
>>>> that fl6.oif is not set and route map failed. From the 
>>>> tcp_v6_send_response function, if the binding address is linklocal,
>>>> fl6.oif is set, but not for global address.
>>>>
>>>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>>>
>>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>
>>> But this looks like a bug to me, so maybe this is something for net
>>> inclusion.
>> I checked the commit log, I think, changes to ipv6 was incompleted in 
>> commit 4c67525849e0b7f4bd4fab leded to this issue . 
>> In tcp_v6_send_response, fl6.oif can't be directly set to iif for global
>> address, but it should not be 0.
> 
> Actually, I wonder if
> 
> if (rt6_need_strict(&fl6.daddr) || !oif)
> 	fl6.flowi6_oif = inet6_iif(skb);
> else
> 	fl6.flowi6_oif = oif;
> 
> would be ok, too, and would ensure that errors with no sockets would
> reach their target with higher probability in case of policy routes.
> 
That would be better, I'll send v4 later
> In routing code we don't do strict lookup unless either we have the
> indication by the socket (if available) or destination address is
> multicast, linklocal or loopback. Otherwise we only favour flowi6_oif
> interfaces.
> 
> Bye,
> 
>   Hannes
> 
> 
> 
