From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/13] Dumping AF_UNIX sockets via netlink
Date: Fri, 16 Dec 2011 13:50:24 -0500 (EST)
Message-ID: <20111216.135024.262929657289610510.davem@davemloft.net>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab1LPSu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:50:27 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 15 Dec 2011 16:42:18 +0400

> Make the unix_diag.ko module, which is the AF_UNIX client for the sock_diag.
> 
> Use the sock_i_ino() as the primary ID key for sockets. This is currently the
> only unique (except for the sk address itself) ID of a unix socket and is de
> facto used in the ss tool to identify sockets. Thus the basic nlk request and
> response structures operate on this ID. Other socket info (sun_name, peer, etc.)
> are reported in the respective NLA-s (patches 8 through 12).
> 
> There's a locking trickery in patch #11. I've tried to study it carefully and
> checked with lockdep, but anyway, please, pay special attention to it.
> 
> The patch for ss tool is also included.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Looks good, applied.

I'm slightly confused by the module alias strings these diag modules
are using, can you explain it to me?

On one side it looks like it wants to see a suffix of "-${AF_INET}-${IPPROTO_TCP}"
but in the macros you pass in one numerical value, which is AF_INET minus the
protocol value.

How does that work?

Thanks.
