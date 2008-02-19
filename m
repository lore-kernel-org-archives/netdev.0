From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 6/17 net-2.6.26] [NETNS]: Default arp parameters lookup.
Date: Tue, 19 Feb 2008 16:16:43 +0100
Message-ID: <47BAF2DB.9060600@fr.ibm.com>
References: <1203406116.27296.1.camel@iris.sw.ru> <1203406297-32725-6-git-send-email-den@openvz.org> <47BA9E0B.6080209@fr.ibm.com> <1203413980.27296.9.camel@iris.sw.ru> <47BAA690.2010504@fr.ibm.com> <1203415549.27296.16.camel@iris.sw.ru> <47BAADEB.3080005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:43886 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757226AbYBSPZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 10:25:17 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1JFPFqY214622
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:25:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1JFPFgt1429514
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:25:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1JFPEiK013335
	for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:25:15 GMT
In-Reply-To: <47BAADEB.3080005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
>> On Tue, 2008-02-19 at 10:51 +0100, Daniel Lezcano wrote:
>>> Denis V. Lunev wrote:
>>>> On Tue, 2008-02-19 at 10:14 +0100, Daniel Lezcano wrote:
>>>>> Denis V. Lunev wrote:
>>>>>> Default ARP parameters should be findable regardless of the context.
>>>>>> Required to make inetdev_event working.
>>>>>>
>>>>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>>>>>> ---
>>>>>>  net/core/neighbour.c |    4 +---
>>>>>>  1 files changed, 1 insertions(+), 3 deletions(-)
>>>>>>
>>>>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>>>>> index c895ad4..45ed620 100644
>>>>>> --- a/net/core/neighbour.c
>>>>>> +++ b/net/core/neighbour.c
>>>>>> @@ -1275,9 +1275,7 @@ static inline struct neigh_parms 
>>>>>> *lookup_neigh_params(struct neigh_table *tbl,
>>>>>>      struct neigh_parms *p;
>>>>>>
>>>>>>      for (p = &tbl->parms; p; p = p->next) {
>>>>>> -        if (p->net != net)
>>>>>> -            continue;
>>>>>> -        if ((p->dev && p->dev->ifindex == ifindex) ||
>>>>>> +        if ((p->dev && p->dev->ifindex == ifindex && p->net == 
>>>>>> net) ||
>>>>>>              (!p->dev && !ifindex))
>>>>>>              return p;
>>>>>>      }
>>>>> If the values are:
>>>>>     p->dev == NULL
>>>>>     ifindex == 0
>>>>>     p->net != net
>>>>>
>>>>> The parms should not be taken into account and the looping must 
>>>>> continue. But with this modification it is not the case, if we 
>>>>> specify parms ifindex == 0, the first parms with the dev field set 
>>>>> to NULL will be taken belonging or not to the right net.
>>>> They should be taken. In the other case inetdev_event will fail for 
>>>> sure
>>>> in the middle. You could check.
>>>>
>>>> These are ARP defaults and I do not see a problem for now to get them.
>>> Because there is a parms default per namespace. So several instances 
>>> of them per nd table. That was the initial approach with Eric's 
>>> patchset.
>>>
>>
>> These changes are not in mainstream and I do not want to touch ARP as
>> this is not a simple thing. In reality ARP will be needed only when
>> we'll have a real device inside a namespace.
>>
>> Right now I prefer to have minimal set of working changes to finish IP
>> and upper layers.
> 
> core/neighbour.c is a common part between several protocols, especially 
> ipv4 and ipv6. If you modify this function just to fit your need in the 
> arp that will block me for ipv6 until you make parms default per 
> namespace. So please, find another way to do that, perhaps just add a 
> helper function.
> 
> I suggest you do parms default per namespace first, it is quite small 
> and easy :)
> 
> Just let me the time to send the copy-parms-default function.

Ok, so after a long discussion with Denis about this patch, I will 
change the ipv6 code to share the neigh->parms. It is not a problem.
Having the behavior of the neighbour subsystem per namespace is not a 
must-have.

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
