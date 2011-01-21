From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Fri, 21 Jan 2011 13:06:57 -0800 (PST)
Message-ID: <20110121.130657.106806953.davem@davemloft.net>
References: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
	<1295593946.2613.52.camel@edumazet-laptop>
	<1295635976.2609.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie@audible.transient.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751321Ab1AUVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 16:06:23 -0500
In-Reply-To: <1295635976.2609.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Jan 2011 19:52:56 +0100

> Here is how I fixed this, thanks again Jamie !
> 
> [PATCH] net: neighbour: pneigh_lookup() doesnt need RTNL

Eric, I don't think we can do this.

Fundamentally, any time a user operation changes the configuration
of the networking, we must hold the RTNL.

Eliding the RTNL for lookups is fine, but for things that change
state it is not.

I therefore think you'll need to rework the arp_ioctl() portions
of the commit that introduced this regression.

