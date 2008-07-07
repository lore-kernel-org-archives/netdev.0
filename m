From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Mon, 07 Jul 2008 12:13:27 +0400
Message-ID: <4871D027.4070504@openvz.org>
References: <486E1074.7040702@openvz.org> <20080705.212138.06508305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58450 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbYGGIQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 04:16:06 -0400
In-Reply-To: <20080705.212138.06508305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Fri, 04 Jul 2008 15:58:44 +0400
> 
>> This is the first small set of MIB statistics netnsization. The easiest
>> case is UDP stats, so I started with this one. If this set is accepted,
>> I will go on step-by-step with adding struct net to all the other stats' 
>> accounting macros, then SNMP_XXX ones and finish with a set than will put 
>> the stats on the struct net and fix appropriate proc files.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> Acked-by: Denis V. Lunev <den@openvz.org>
> 
> Applied, thanks Pavel.
> 
> Are we going to provide some way for an administrator to fetch
> stats from the perspective of all namespaces?  I know the idea
> is seperation with this stuff, but admins are going to want
> something like that.

Well, if we want to get the stats for each namespace separately, then
this ability is already present. Since this statistics is shown via the
/proc/net files and the /proc/net itself is seen via the /proc/<pid>/net,
then we can walk the init-s of all the containers in the system and dump
this info.

The problem that is to be solved with this approach is how to get these
init-s :) But since finding any namespace by some task living in it is a
common practice now (netdev moving, sys_hijack) this one will be solved.

BTW, are there some plans about implementing some netlink-based fetcher
of this statistics? If so, then I think it's worth making this engine
namespaces aware from the very beginning.

Thanks,
Pavel

