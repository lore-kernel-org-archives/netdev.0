From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 5 Jun 2012 13:56:40 +0200
Message-ID: <20120605115640.GC27795@secunet.com>
References: <1338888507.2760.2146.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52678 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619Ab2FEL4s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 07:56:48 -0400
Content-Disposition: inline
In-Reply-To: <1338888507.2760.2146.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 11:28:27AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
> the routing cache) added a race :
> 
> Before freeing an inetpeer, we must respect a RCU grace period, and make
> sure no user will attempt to increase refcnt.
> 

As already mentioned in the other mail. In this case, I think
we can just delete the inetpeer once the refcount got zero.
