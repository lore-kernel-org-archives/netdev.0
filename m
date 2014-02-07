From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next] bonding: don't permit slaves to change
 their mtu independently
Date: Fri, 7 Feb 2014 11:56:46 +0800
Message-ID: <52F4597E.8010401@huawei.com>
References: <52E343AD.3080402@huawei.com> <20140206.194107.170476650427156102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7330 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaBGD5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 22:57:23 -0500
In-Reply-To: <20140206.194107.170476650427156102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/7 11:41, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Sat, 25 Jan 2014 12:55:09 +0800
> 
>> I have come to a conclusion by testing all modes for mtu changing:
>>
>> 1). If the slaves support changing mtu and no need to restart the device,
>>     just like virtual nic, the master will not lost any packages for all
>>     mode.
>>
>> 2). If the slaves support changing mtu and need to restart the device,
>>     just like Intel 82599, the AB, 802.3, ALB and TLB mode may lost
>>     packages, but other modes could work well.
>>
>> The reason is that when the slave's mtu has been changed, the slave's hw will
>> restart, if the slave is current active slave, the master may set the
>> slave to backup state and reselect a new slave, after the reselect processing,
>> the master could work again, but if in load-balance mode, the master could
>> select another active slave to send and recv packages.
>>
>> So the best way to fix the problem is don't permit slave to change their
>> mtu independently.
>>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> Without any review, I'm not applying this patch, sorry.
> 
> 
Ok, and I found some new issue for this patch, maybe need more discussion.

Regards
Ding
