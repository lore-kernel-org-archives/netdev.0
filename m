From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 6/17 net-2.6.26] [NETNS]: Default arp parameters lookup.
Date: Tue, 19 Feb 2008 10:51:12 +0100
Message-ID: <47BAA690.2010504@fr.ibm.com>
References: <1203406116.27296.1.camel@iris.sw.ru> <1203406297-32725-6-git-send-email-den@openvz.org> <47BA9E0B.6080209@fr.ibm.com> <1203413980.27296.9.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:4935 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbYBSJ7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 04:59:36 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1J9xZSg513536
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 09:59:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1J9xZxR1695824
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 09:59:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1J9xYvm016896
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 09:59:35 GMT
In-Reply-To: <1203413980.27296.9.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Tue, 2008-02-19 at 10:14 +0100, Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Default ARP parameters should be findable regardless of the context.
>>> Required to make inetdev_event working.
>>>
>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>>> ---
>>>  net/core/neighbour.c |    4 +---
>>>  1 files changed, 1 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>> index c895ad4..45ed620 100644
>>> --- a/net/core/neighbour.c
>>> +++ b/net/core/neighbour.c
>>> @@ -1275,9 +1275,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
>>>  	struct neigh_parms *p;
>>>
>>>  	for (p = &tbl->parms; p; p = p->next) {
>>> -		if (p->net != net)
>>> -			continue;
>>> -		if ((p->dev && p->dev->ifindex == ifindex) ||
>>> +		if ((p->dev && p->dev->ifindex == ifindex && p->net == net) ||
>>>  		    (!p->dev && !ifindex))
>>>  			return p;
>>>  	}
>> If the values are:
>> 	p->dev == NULL
>> 	ifindex == 0
>> 	p->net != net
>>
>> The parms should not be taken into account and the looping must 
>> continue. But with this modification it is not the case, if we specify 
>> parms ifindex == 0, the first parms with the dev field set to NULL will 
>> be taken belonging or not to the right net.
> 
> They should be taken. In the other case inetdev_event will fail for sure
> in the middle. You could check.
> 
> These are ARP defaults and I do not see a problem for now to get them.

Because there is a parms default per namespace. So several instances of 
them per nd table. That was the initial approach with Eric's patchset.

