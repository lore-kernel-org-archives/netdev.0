From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 22:09:23 -0500
Message-ID: <20060421030923.GN26746@pb15.lixom.net>
References: <20060420213305.GK26746@pb15.lixom.net> <c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com> <20060420233343.GL26746@pb15.lixom.net> <20060420.174438.15249396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy.grover@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:62169 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S932217AbWDUDJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 23:09:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060420.174438.15249396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 05:44:38PM -0700, David S. Miller wrote:
> From: Olof Johansson <olof@lixom.net>
> Date: Thu, 20 Apr 2006 18:33:43 -0500
> 
> > On Thu, Apr 20, 2006 at 03:14:15PM -0700, Andrew Grover wrote:
> > > In
> > > addition, there may be workloads (file serving? backup?) where we
> > > could do a skb->page-in-page-cache copy and avoid cache pollution?
> > 
> > Yes, NFS is probably a prime example of where most of the data isn't
> > looked at; just written to disk. I'm not sure how well-optimized the
> > receive path is there already w.r.t. avoiding copying though. I don't
> > remember seeing memcpy and friends being high on the profile when I
> > looked at SPECsfs last.
> 
> If that makes sense then the cpu copy can be made to use non-temporal
> stores.

I'm not sure that would buy anything. I didn't mean caching was
necessarily bad, just that lack of it might not hurt as much under that
specific type of workload.

NFS has to look at RPC/NFS headers anyway, so it will benefit from the
cache being warm.


-Olof
