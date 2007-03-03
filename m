From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 21:59:05 -0800 (PST)
Message-ID: <20070302.215905.74747266.davem@davemloft.net>
References: <20070302.151803.74748558.davem@davemloft.net>
	<E1HNMxB-0000MP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933387AbXCCF7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 00:59:09 -0500
In-Reply-To: <E1HNMxB-0000MP-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 03 Mar 2007 16:38:45 +1100

> This is using packet_bind_spkt which uses a name instead of ifindex.

So it should be just fine, it should be binding to a specific
device (by name instead of ifindex) and therefore it should
only trigger the pt_all hook when the packet arrives on that
specific device.

> As you may recall, I've made a patch to convert it to use the new
> (actually it's not-so-new anymore) AF_PACKET interface.

That's right.

So it's still a mystery why dhcp is causing bridge devices
to trigger the network tap paths on Stephen's machine.
