From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Mon, 26 Jun 2006 17:49:41 +0200
Message-ID: <44A00215.2040608@fr.ibm.com>
References: <20060609210202.215291000@localhost.localdomain> <20060609210625.144158000@localhost.localdomain> <20060626134711.A28729@castle.nmd.msu.ru> <449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:3696 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750718AbWFZPtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:49:55 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060626192751.A989@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Then you lose the ability for each namespace to have its own routing entries.
> Which implies that you'll have difficulties with devices that should exist
> and be visible in one namespace only (like tunnels), as they require IP
> addresses and route.

I mean instead of having the route tables private to the namespace, the 
routes have the information to which namespace they are associated.

> 
>	- keep a "flat" model where network ressources have a new identifier 
>>which is the network namespace pointer. The idea is to move only some 
>>network informations private to the namespace (eg port range, stats, ...)
> 
> 
> Sorry, I don't get the second idea with only some information private to
> namespace.
> 
> How do you want TCP_INC_STATS macro look?

I was thinking in TCP_INC_STATS(net_ns, field) 
SNMP_INC_STATS(net_ns->tcp_stat, field)

> In my concept, it would be something like
> #define TCP_INC_STATS(field) SNMP_INC_STATS(current_net_ns->tcp_stat, field)
> where tcp_stat is a TCP statistics array inside net_namespace.

