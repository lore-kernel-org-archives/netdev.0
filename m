From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc layer
Date: Wed, 9 Oct 2013 03:43:24 +0200
Message-ID: <20131009014324.GA24368@order.stressinduktion.org>
References: <52327F00.4040802@cn.fujitsu.com> <5232806B.6050601@cn.fujitsu.com> <20130917.202936.2080212548361553334.davem@davemloft.net> <20130918013903.GC8947@order.stressinduktion.org> <5239076A.4080406@cn.fujitsu.com> <20130918041337.GD8947@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49380 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857Ab3JIBn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 21:43:26 -0400
Content-Disposition: inline
In-Reply-To: <20130918041337.GD8947@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Duan!

On Wed, Sep 18, 2013 at 06:13:37AM +0200, Hannes Frederic Sowa wrote:
> Especially because redirects also help in the on-link determination (same
> RFC, section 8), I changed my mind and am still in favour of updating it
> in the ndisc layer. In my opinion we just have to consider all routing
> tables and apply the update to every one which carries a valid next hop
> to the source of the redirect (under consideration of the destination).
> 
> This will be important if we actually try to get linux to correctly
> implement the ipv6 subnet model (RFC 5942, Section 4 Rule 1). In that
> case we are not allowed to assume nodes on-link even if they would match
> the same prefix as a locally configured address.

I am playing around with a simple patch which does suppress adding routing
information for the on-link assumption we currently do in linux.

Are you intereseted in following up on this? I still do think we should update
not only the routing table the socket uses but all routing tables which have a
valid route towards the router which emitted the redirect.

I try to check if we actually handle redirect messages when ECMP routes are in
use correctly.

Greetings,

  Hannes
