From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 0/5] bonding: Patchset for rcu use in bonding
Date: Fri, 30 Aug 2013 09:37:25 +0800
Message-ID: <521FF755.6050306@huawei.com>
References: <521D7AA3.6030205@huawei.com> <521F5AA3.4030105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:8792 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089Ab3H3Bhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 21:37:50 -0400
In-Reply-To: <521F5AA3.4030105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/29 22:28, Nikolay Aleksandrov wrote:
> On 08/28/2013 06:20 AM, Ding Tianhong wrote:
>> Hi:
>>
>> The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
>> replace and add more rcu list function.
>> fix a bug to protect bonding_store_xmit_hash().
>>
>> I test well and no problems found till now.
>>
>> Ding Tianhong (3):
>> Wang Yufen (1):
>> Yang Yingliang (1):
>>   bonding: simplify and use RCU protection for 3ad xmit path
>>   bonding: replace read_lock to rcu_read_lock for
>>   bond_3ad_get_active_agg_info()
>>   bonding: add rtnl lock for bonding_store_xmit_hash
>>   bonding: restructure and simplify bond_for_each_slave_next()
>>   bonding: use RCU protection for alb xmit path
>>
>>  drivers/net/bonding/bond_3ad.c   | 35 +++++++++++++++-------------------
>>  drivers/net/bonding/bond_alb.c   | 23 ++++++++++------------
>>  drivers/net/bonding/bond_main.c  |  6 ++----
>>  drivers/net/bonding/bond_sysfs.c |  4 ++++
>>  drivers/net/bonding/bonding.h    | 41 ++++++++++++++++++++++++++++++++++++----
>>  5 files changed, 68 insertions(+), 41 deletions(-)
>>
> Thanks for the work, I was on vacation and travelling after my initial RCU
> conversion so I got a little behind with these conversions, my idea was quite
> different :-)
> Anyway, I'd also appreciate some benchmarks, also some more information on what
> type of testing did you run ?
> I've given some preliminary comments to the patches, I'll have to think more
> about them in this form.
> 
> Cheers,
>  Nik
> 
> .

It looks like a wonderful vocation :).
I focus on the 3ad and alb mode, because the modify was manly for xmit, so my test environment was consist of 4 Intel82599 10G card, and use mode lacp ,alb.
I use iperf to test, after the patch, the performance was a little better and no problem
occurs. 

> 
