From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom the host TCP port space.
Date: Mon, 20 Aug 2007 13:43:18 +0400
Message-ID: <20070820094317.GA14817@2ka.mipt.ru>
References: <20070819.174017.77241227.davem@davemloft.net> <8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sean.hefty@intel.com,
	netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	jeff@garzik.org
To: Felix Marti <felix@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34698 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbXHTJoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 05:44:09 -0400
Content-Disposition: inline
In-Reply-To: <8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 19, 2007 at 05:47:59PM -0700, Felix Marti (felix@chelsio.com) wrote:
> [Felix Marti] David and Herbert, so you agree that the user<>kernel
> space memory copy overhead is a significant overhead and we want to
> enable zero-copy in both the receive and transmit path? - Yes, copy

It depends. If you need to access that data after received, you will get
cache miss and performance will not be much better (if any) that with
copy.

> avoidance is mainly an API issue and unfortunately the so widely used
> (synchronous) sockets API doesn't make copy avoidance easy, which is one
> area where protocol offload can help. Yes, some apps can resort to
> sendfile() but there are many apps which seem to have trouble switching
> to that API... and what about the receive path?

There is number of implementations, and all they are suitable for is 
to have recvfile(), since this is likely the only case, which can work 
without cache.

And actually RDMA stack exist and no one said it should be thrown away
_until_ it messes with main stack. It started to speal ports. What will
happen when it gest all port space and no new legal network conection
can be opened, although there is no way to show to user who got it?
What will happen if hardware RDMA connection got terminated and software
could not free the port? Will RDMA request to export connection reset
functions out of stack to drop network connections which are on the ports
which are supposed to be used by new RDMA connections?

RDMA is not a problem, but how it influence to the network stack is.
Let's better think about how to work correctly with network stack (since
we already have that cr^Wdifferent hardware) instead of saying that
others do bad work and do not allow shiny new feature to exist.

-- 
	Evgeniy Polyakov
