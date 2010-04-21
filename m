From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Tue, 20 Apr 2010 17:14:16 -0700 (PDT)
Message-ID: <20100420.171416.157904027.davem@davemloft.net>
References: <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	<4BCE3D8D.3030500@candelatech.com>
	<1271808314.7895.614.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, gasparch@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753990Ab0DUAOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:14:12 -0400
In-Reply-To: <1271808314.7895.614.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Apr 2010 02:05:14 +0200

> [PATCH net-next-2.6] tcp: remove bsockets count
> 
> Counting number of bound sockets to avoid a loop is buggy, since we cant
> know how many IP addresses are in use. When threshold is reached, we try
> 5 random slots and can fail while there are plenty available ports.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Hmmm, yes indeed it seems there are improper assumptions made by
this scheme.

This is a tricky area, so I'll wait for some test results from the
reporter and study the code over a few times myself to make sure
we get this right.
