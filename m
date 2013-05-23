From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after netdev_rx_handler_unregister
Date: Thu, 23 May 2013 15:50:46 +0800
Message-ID: <519DCA56.9020509@huawei.com>
References: <519C8504.1080906@huawei.com>  <1369223145.3301.308.camel@edumazet-glaptop> <519D73CA.8090200@huawei.com> <1369273937.3301.377.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:29167 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3EWHvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:51:36 -0400
In-Reply-To: <1369273937.3301.377.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/23 9:52, Eric Dumazet wrote:
> On Thu, 2013-05-23 at 09:41 +0800, dingtianhong wrote:
> 
>> I totally understand the commit [1] and know the problem that you met at that time,
>> but its not a net core problem, its drivers problem, the function synchronize_net()
>> need to follow netdev_rx_handler_unregister() even though netdev_rx_handler_unregister()
>> has its own synchronize_net(), the commit [2] fcd99434f fix drivers problem follow your
>> opinion, but miss synchronize_net(),so add it.
>>
> 
> No, driver is fine.
> 
> You absolutely not explained why you believe this is needed.
> 
> After netdev_rx_handler_unregister(), no packet will be delivered to the
> bonding driver.
> 
> 
ok, I agree with the views of yours, it is no way to access the rx_handler_data after that.

> 
> 
> 
