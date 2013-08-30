From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 4/5] bonding: restructure and simplify bond_for_each_slave_next()
Date: Fri, 30 Aug 2013 11:37:12 +0800
Message-ID: <52201368.4070200@huawei.com>
References: <521D7AC7.6090508@huawei.com> <521F59EE.1080408@redhat.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:47446 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3H3Dhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:37:41 -0400
In-Reply-To: <521F59EE.1080408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>  			slave->link = BOND_LINK_BACK;
>>  			bond_set_slave_active_flags(slave);
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index ecb5d1d..7670584 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -119,14 +119,25 @@
>>   * bond_for_each_slave_from - iterate the slaves list from a starting point
>>   * @bond:	the bond holding this list.
>>   * @pos:	current slave.
>> - * @cnt:	counter for max number of moves
>>   * @start:	starting point.
>>   *
>>   * Caller must hold bond->lock
>>   */
>> -#define bond_for_each_slave_from(bond, pos, cnt, start) \
>> -	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
>> -	     cnt++, pos = bond_next_slave(bond, pos))
>> +#define bond_for_each_slave_from(bond, pos, start) \
>> +	for (pos = bond_next_slave(bond, start); pos && pos != start; \
>> +			pos = bond_next_slave(bond, pos))
>> +
>> +/**
>> + * bond_for_each_slave_from_rcu - iterate the slaves list from a starting point
>> + * @bond:	the bond holding this list.
>> + * @pos:	current slave.
>> + * @start:	starting point.
>> + *
>> + * Caller must hold rcu_read_lock
>> + */
>> +#define bond_for_each_slave_from_rcu(bond, pos, start) \
>> +	for (pos = bond_next_slave_rcu(bond, start); pos && pos != start; \
>> +			pos = bond_next_slave_rcu(bond, pos))
>>  
> One question here: what if "start" gets deleted while we're traversing the list,
> could this lead to an infinite loop ?
> 

agree, so the start should not be delete while traversing the list, the func should not run
without protection. 

>>  /**
>>   * bond_for_each_slave - iterate over all slaves
>>
> 
> 
> .
> 
