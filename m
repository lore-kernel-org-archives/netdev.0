From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Mon, 07 Jul 2008 12:19:03 +0200
Message-ID: <4871ED97.70806@fr.ibm.com>
References: <486E1074.7040702@openvz.org> <20080705.212138.06508305.davem@davemloft.net> <4871D027.4070504@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	den@openvz.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:30063 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbYGGKTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 06:19:24 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m67AJMlc123360
	for <netdev@vger.kernel.org>; Mon, 7 Jul 2008 10:19:22 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m67AJLld1052736
	for <netdev@vger.kernel.org>; Mon, 7 Jul 2008 11:19:21 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m67AJKIf028654
	for <netdev@vger.kernel.org>; Mon, 7 Jul 2008 11:19:20 +0100
In-Reply-To: <4871D027.4070504@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> David Miller wrote:
>> From: Pavel Emelyanov <xemul@openvz.org>
>> Date: Fri, 04 Jul 2008 15:58:44 +0400
>>
>>> This is the first small set of MIB statistics netnsization. The easiest
>>> case is UDP stats, so I started with this one. If this set is accepted,
>>> I will go on step-by-step with adding struct net to all the other stats' 
>>> accounting macros, then SNMP_XXX ones and finish with a set than will put 
>>> the stats on the struct net and fix appropriate proc files.
>>>
>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>> Acked-by: Denis V. Lunev <den@openvz.org>
>> Applied, thanks Pavel.
>>
>> Are we going to provide some way for an administrator to fetch
>> stats from the perspective of all namespaces?  I know the idea
>> is seperation with this stuff, but admins are going to want
>> something like that.
> 
> Well, if we want to get the stats for each namespace separately, then
> this ability is already present. Since this statistics is shown via the
> /proc/net files and the /proc/net itself is seen via the /proc/<pid>/net,
> then we can walk the init-s of all the containers in the system and dump
> this info.
> 
> The problem that is to be solved with this approach is how to get these
> init-s :) But since finding any namespace by some task living in it is a
> common practice now (netdev moving, sys_hijack) this one will be solved.
> 
> BTW, are there some plans about implementing some netlink-based fetcher
> of this statistics? If so, then I think it's worth making this engine
> namespaces aware from the very beginning.


Shouldn't be interesting to handle the network namespaces directly with 
the iproute command ?

  * ip netns add <name>
  * ip netns del <name>
  * ip netns <oldname> set name <newname>
  * ip netns show

When a network namespace is created via clone|unshare, the name is 
automatically the pid of the creator.

In order to track the namespace, we can add an entry in /proc/net (aka 
/proc/<pid>/net) named "name" which contains the name of the namespace.
I heard Eric is thinking about a netnsfs.

 From a larger perspective, the iproute command with a new "netns" 
subcommand can be enhanced to have more features, for example the freeze 
and resume for the network.

  * ip netns set down <name>
  * ip netns set up <name>

So having the netns binded, we can plug the known subcommand (link, ip, 
...) with the netns features. For examples:

  * ip addr add 1.2.3.4/24 dev eth0 netns foo






