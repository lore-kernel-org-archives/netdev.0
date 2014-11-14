From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 13:38:29 -0500 (EST)
Message-ID: <20141114.133829.1437047454714311242.davem@davemloft.net>
References: <1415978022.15154.31.camel@localhost>
	<1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1415979978.15154.41.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, pshelar@nicira.com, jesse@nicira.com,
	jay.vosburgh@canonical.com, discuss@openvswitch.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbaKNSid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 13:38:33 -0500
In-Reply-To: <1415979978.15154.41.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 14 Nov 2014 16:46:18 +0100

> I would still like to see the current proposed fix getting applied and
> we can do this on-top. The inline call after this patch reassembles a
> direct function call, so besides the long list of clobbers, it should
> still be pretty fast.

I would rather revert the change entirely until it is implemented
properly.

Also, I am strongly of the opinion that this is a mis-use of the
alternative call interface.  It was never intended to be used for
things that can make real function calls.

You can add a million clobbers, or a trampoline, it's still using a
facility in a manner for which it was not designed.

This means a new interface with a new name and with capabilities
explicitly supporting this case are in order.

Thanks.
