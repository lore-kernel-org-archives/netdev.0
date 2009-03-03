From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] netns : fix addrconf_ifdown kernel panic
Date: Tue, 03 Mar 2009 01:07:05 -0800 (PST)
Message-ID: <20090303.010705.142659291.davem@davemloft.net>
References: <20090227182658.569183560@mai.toulouse-stg.fr.ibm.com>
	<20090227183118.656583844@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@gmail.com, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbZCCJHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 04:07:23 -0500
In-Reply-To: <20090227183118.656583844@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 27 Feb 2009 19:26:59 +0100

> When a network namespace is destroyed the network interfaces are
> all unregistered, making addrconf_ifdown called by the netdevice
> notifier. 
> In the other hand, the addrconf exit method does a loop on the network
> devices and does addrconf_ifdown on each of them. But the ordering of 
> the netns subsystem is not right because it uses the register_pernet_device
> instead of register_pernet_subsys. If we handle the loopback as
> any network device, we can safely use register_pernet_subsys.
> 
> But if we use register_pernet_subsys, the addrconf exit method will do
> exactly what was already done with the unregistering of the network
> devices. So in definitive, this code is pointless.
> 
> I removed the netns addrconf exit method and moved the code to the
> addrconf cleanup function.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
