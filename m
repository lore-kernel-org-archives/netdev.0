From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 1/2] flowcache: Make flow cache name space
 aware
Date: Thu, 16 Jan 2014 11:19:46 +0100
Message-ID: <20140116101946.GM31491@secunet.com>
References: <1389771254-8738-1-git-send-email-fan.du@windriver.com>
 <1389771254-8738-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52903 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbaAPKTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:19:49 -0500
Content-Disposition: inline
In-Reply-To: <1389771254-8738-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 03:34:13PM +0800, Fan Du wrote:
> Inserting a entry into flowcache, or flushing flowcache should be based
> on per net scope. The reason to do so is flushing operation from fat
> netns crammed with flow entries will also making the slim netns with only
> a few flow cache entries go away in original implementation.
> 
> Since flowcache is tightly coupled with IPsec, so it would be easier to
> put flow cache global parameters into xfrm namespace part.

With this change the flow cache is not globally available any more,
it becomes a part of IPsec. IPsec is the only user of the flow cache
and I guess noone else want to use it (we removed the routing cache
to avoid such caching recently).

So I would not mind to move this into IPsec, but I want to see an ack
from David before I take this into ipsec-next.
