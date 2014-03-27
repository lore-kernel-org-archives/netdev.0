From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next v3 2/2] net: tcp_ipv6 policy route issue
Date: Thu, 27 Mar 2014 10:00:34 +0800
Message-ID: <53338642.1060405@huawei.com>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com> <1395642322-9404-2-git-send-email-wangyufen@huawei.com> <20140326070548.GF22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:24917 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbaC0CBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 22:01:50 -0400
In-Reply-To: <20140326070548.GF22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/26 15:05, Hannes Frederic Sowa wrote:
> On Mon, Mar 24, 2014 at 02:25:22PM +0800, Wangyufen wrote:
>> From: Wang Yufen <wangyufen@huawei.com>
>>
>> The issue raises when adding policy route, specify a particular
>> NIC as oif, the policy route did not take effect. The reason is
>> that fl6.oif is not set and route map failed. From the 
>> tcp_v6_send_response function, if the binding address is linklocal,
>> fl6.oif is set, but not for global address.
>>
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> But this looks like a bug to me, so maybe this is something for net
> inclusion.
I checked the commit log, I think, changes to ipv6 was incompleted in 
commit 4c67525849e0b7f4bd4fab leded to this issue . 
In tcp_v6_send_response, fl6.oif can't be directly set to iif for global
address, but it should not be 0.

> 
> Thanks,
> 
>   Hannes
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
