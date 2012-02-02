From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 0/4] Fix routing metrics
Date: Thu, 2 Feb 2012 11:11:41 +0100
Message-ID: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48739 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab2BBKLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:11:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment we initialize the routing metrics with the, on the inetpeer
cached values in rt_init_metrics(). So if we have the metrics cached on the
inetpeer, we ignore the user configured fib_metrics. This leads to the fact 
that we can't configure the mtu, hoplimit etc. if we have learned metrics 
cached. This patchset adds a possibility to invalidate and exchange the
cached inetpeer metrics. In detail it does:

1. Allocate the inetpeer metrics dynamically and add a reference
to the inetpeer.

2. Remove the direct reference of the inetpeer metrics from
dst->_metrics and access the metrics via the inetpeer reference
of the route. This makes it possible to exchange the inetpeer
metrics if they get invalidated.

3. Protect the inetpeer metrics with rcu.

4. Add a peer_genid to invalidate the metrics. When the peer_genid
is incremeted we allocate new metrics and exchange the metrics
pointer of the inetpeer.

For the case that such a approach is acceptable, I have another patch
to unify peer_genid and redirect_genid.
