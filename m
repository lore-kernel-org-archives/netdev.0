From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc layer
Date: Wed, 18 Sep 2013 03:39:03 +0200
Message-ID: <20130918013903.GC8947@order.stressinduktion.org>
References: <52327F00.4040802@cn.fujitsu.com> <5232806B.6050601@cn.fujitsu.com> <20130917.202936.2080212548361553334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35306 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab3IRBjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 21:39:05 -0400
Content-Disposition: inline
In-Reply-To: <20130917.202936.2080212548361553334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 08:29:36PM -0400, David Miller wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Fri, 13 Sep 2013 11:03:07 +0800
> 
> > From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> > 
> > Do the whole verification and route updating in ndisc
> > lay and then just call into icmpv6_notify() to notify
> > the upper protocols.
> > 
> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> This is completely broken, and I believe your patch set fundamentally
> is too.
> 
> We absolutely _must_ handle the redirect at the socket level when
> we are able to, otherwise we cannot specify the mark properly and
> the mark is an essential part of the key used to find the correct
> route to work with.
> 
> I am not applying this patch series until you deal with this
> deficiency.  I am not willing to consider changes which stop using the
> more precise keying information available from a socket.

Oh, Duan, I am very sorry for not catching this earlier. We use the
sk->mark to select the proper routing table where we clone the rt6_info into.
And we only get that value out of the sockets. I missed that. We should leave
the redirect logic in the socket layer where it is possible.

But parts of this series are still valid. We need to fix redirects for tunnels
and I do think we can still simplify some code in the error handlers.

Thanks for pointing this out,

  Hannes
