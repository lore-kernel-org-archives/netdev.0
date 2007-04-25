From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 13:18:47 -0700 (PDT)
Message-ID: <20070425.131847.26277170.davem@davemloft.net>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
	<alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, security@kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, jaco@kroon.co.za
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993070AbXDYUSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:18:39 -0400
In-Reply-To: <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 25 Apr 2007 13:15:12 -0700 (PDT)

> If so, shouldn't we also have some safety-net to make sure it doesn't 
> still get routed back forever, ie adding something like
> 
> 	if (!pid) {
> 		skb_free(skb);
> 		return -EINVAL;
> 	}
> 
> or similar? I don't know the netlink layer from a dolphin, but if the old 
> code could cause infinite recursion, it sounds like the new code could too 
> with the right pid, since the only change is the choice of pid.

Netlink pids are more like "port numbers" in the socket sense, do
not confuse them with process pids or similar.

The kernel explicitly assigns them to sockets, and zero is special.
The fact that the process pid of the socket creator is used as
an initial selection heuristic, is just that, a heuristic.

Alexey's fix is %100 the right way to go IMHO.
