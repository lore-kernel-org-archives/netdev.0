From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Ipvlan should return an error when an address is
 already in use.
Date: Tue, 03 Jan 2017 10:55:28 -0500 (EST)
Message-ID: <20170103.105528.1616978923771083764.davem@davemloft.net>
References: <20161231041058.GC2448@templeofstupid.com>
        <f7td1g49m8n.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kjlx@templeofstupid.com, maheshb@google.com, netdev@vger.kernel.org
To: aconole@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752862AbdACQEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:04:23 -0500
In-Reply-To: <f7td1g49m8n.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@redhat.com>
Date: Tue, 03 Jan 2017 10:50:00 -0500

>> @@ -489,7 +490,12 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>>  	   Notifier will trigger FIB update, so that
>>  	   listeners of netlink will know about new ifaddr */
>>  	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
>> -	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
>> +	ret = blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
> 
> Why are you doing this assignment if you aren't using the result?
> 
>> +	ret = notifier_to_errno(ret);
>> +	if (ret) {
>> +		__inet_del_ifa(in_dev, ifap, 1, NULL, portid);
>> +		return ret;
>> +	}

'ret' assignment is being used, via notifier_to_errno().
