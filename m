From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH] Ipvlan should return an error when an address is already in use.
Date: Tue, 03 Jan 2017 14:24:43 -0500
Message-ID: <f7ta8b87xqc.fsf@redhat.com>
References: <20161231041058.GC2448@templeofstupid.com>
        <f7td1g49m8n.fsf@redhat.com>
        <20170103.105528.1616978923771083764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kjlx@templeofstupid.com, maheshb@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44184 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935609AbdACTYp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 14:24:45 -0500
In-Reply-To: <20170103.105528.1616978923771083764.davem@davemloft.net> (David
        Miller's message of "Tue, 03 Jan 2017 10:55:28 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Aaron Conole <aconole@redhat.com>
> Date: Tue, 03 Jan 2017 10:50:00 -0500
>
>>> @@ -489,7 +490,12 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
>>>  	   Notifier will trigger FIB update, so that
>>>  	   listeners of netlink will know about new ifaddr */
>>>  	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
>>> -	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
>>> +	ret = blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
>> 
>> Why are you doing this assignment if you aren't using the result?
>> 
>>> +	ret = notifier_to_errno(ret);
>>> +	if (ret) {
>>> +		__inet_del_ifa(in_dev, ifap, 1, NULL, portid);
>>> +		return ret;
>>> +	}
>
> 'ret' assignment is being used, via notifier_to_errno().

d'oh!  should have had more coffee - sorry for the noise.
