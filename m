From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 17:18:42 +0200
Message-ID: <48E394D2.5090709@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org> <48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com> <1222872885.23573.64.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:40893 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbYJAPS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:18:58 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m91FInov037724
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 15:18:49 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91FInK73883120
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:18:49 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91FIjLp009661
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 17:18:45 +0200
In-Reply-To: <1222872885.23573.64.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Wed, 2008-10-01 at 15:46 +0200, Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> On Wed, 2008-10-01 at 14:31 +0200, Daniel Lezcano wrote:
>>>> Pavel Emelyanov wrote:
>>>>>> So there are 2 cases:
>>>>>>   * full isolation : restriction on VPS
>>>>>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>>>>>
>>>>>> Looks like we need an option per namespace to reduce the isolation for 
>>>>>> af_unix sockets :)
>>>>>>   - on (default): current behaviour => full isolation
>>>>>>   - off : partial isolation
>>>>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
>>>> Yes.
>>> I do not see much sense with sysctl as:
>>> - check (cross-connected sockets) is required as we can start namespace
>>>   with already opened socket
>> Check when checkpointing ? If you inherit a socket from your parent 
>> namespace, this socket belongs to your parent and you should not 
>> checkpoint it, no ?
>>
>> In case you allow cross-connected sockets, this check is mandatory I agree.
>>
>>> - this kind of sharing is not implicit but explicit as normal isolated
>>>   containers _must_ have separate filesystems. In this case this
>>>   sharing requires explicit host administrator action to link socket
>>>   between containers
>> What are "normal isolated containers" ? Are they OpenVZ containers ? 
>> These containers belong to the system containers family. What happens 
>> with application containers, if I want to share the filesystem without 
>> breaking the isolation of the afunix sockets ?
> 
> then you are doomed as you will have a FIFO opened from 2 namespaces and
> checking the absences of external references is still mandatory
>> The current code provides full isolation and this is in mainline. I 
>> don't think it is reasonable to change that. What I propose is to keep 
>> the current behaviour.
>>
>> When you create a network namespace, you can change the behaviour inside 
>> this namespace via /proc/sys/net/unix/isolated (for example).
>>
>> This option allows:
>> 1 - to connect to af_unix not belonging to the container
>> 2 - to accept af_unix connection from outside the container (avoid a 
>> container to forbid the checkpoint of another container);
> 
> this should be at least per/namespace option controlled from parent
> container from my POW

Yes per namespace, I agree.

If the option is controlled by the parent and it is done by sysctl, you 
will have to make proc/sys per namespace like Pavel did with /proc/net, no ?

