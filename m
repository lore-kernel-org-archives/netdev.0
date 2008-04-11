From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/14 (3 subsets)] Make tuns and vlans devices work per-net.
Date: Fri, 11 Apr 2008 19:57:25 +0400
Message-ID: <47FF8A65.7030605@openvz.org>
References: <47FE2AD4.9080609@openvz.org> <47FF86FE.7030209@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39944 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759907AbYDKP64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 11:58:56 -0400
In-Reply-To: <47FF86FE.7030209@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Pavel Emelyanov wrote:
>> Hi, guys.
>>
>> I've recently sent a TUN devices virtualization, but it was rejected
>> by Dave, since the struct net is becoming a dumping ground.
>>
>> I agree with him - we really need some way to register on-net data
>> dynamically. That's my view of such a thing and two examples of how
>> to use it (TUN and VLAN devices virtualization).
>>
>> If this will be found good, I'll send these sets to David, hoping he
>> will accept them :)
> 
> Pavel,
> 
> seems to be a smart solution :)

Thanks :) However, I've already found a bug in the 1st patch (already fixed).

> I am just afraid with the performances when the network resources are to 
> be accessed in the fast path like a routing table (that seems not to be 
> the case for tun and vlan). Shall we assume the fast path should always 
> go to struct net and non critical path can go to net_generic ?

Hm... I put call to net_generic() into tunnels rcv call and measured 
the performance with netperf - no performance penalty. I tried to make 
net_generic() work w/o any locks and looks like I've managed to make 
it fast enough :)

I think, that core kernel code and protocols should/may use the struct 
net, while modules are better to work via generic pointers. However, if
the generic pointers cause noticeable performance degradation, then we
may ask Dave to bear with on-net members :)

>    -- Daniel
> 

