From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next] bonding: don't permit slaves to change
 their mtu independently
Date: Fri, 7 Feb 2014 12:19:57 +0800
Message-ID: <52F45EED.4020108@huawei.com>
References: <52E343AD.3080402@huawei.com> <20140201.165340.704074184414791614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:28087 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaBGEUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 23:20:33 -0500
In-Reply-To: <20140201.165340.704074184414791614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/2 8:53, David Miller wrote:
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
> This has been rotting in patchwork for a week, and desperately needs
> someone to review it.
> 
> 
Self Naked, this patch did not consider the bond dev MTU changing, because
if I forbidden the slave to change mtu in any way, the bond will not change
its own mtu anymore, so I should think more about this situation. Sorry for the
noise.

Regards
Ding
