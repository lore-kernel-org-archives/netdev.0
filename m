From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] vxlan: Move socket initialization to within rtnl
 scope
Date: Wed, 18 Mar 2015 22:05:38 -0400 (EDT)
Message-ID: <20150318.220538.841553909588344081.davem@davemloft.net>
References: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
	<42176242983d6204ad39dfad98055e6cf7a1ca61.1426700794.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbCSCFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:05:40 -0400
In-Reply-To: <42176242983d6204ad39dfad98055e6cf7a1ca61.1426700794.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 18 Mar 2015 14:50:44 -0300

> Currently, if a multicast join operation fail, the vxlan interface will
> be UP but not functional, without even a log message informing the user.
> 
> Now that we can grab socket lock after already having rntl, we don't
> need to defer socket creation and multicast operations. By not deferring
> we can do proper error reporting to the user through ip exit code.
> 
> This patch thus removes all deferred work that vxlan had and put it back
> inline. Now the socket will only be created, bound and join multicast
> group when one bring the interface up, and will undo all that as soon as
> one put the interface down.
> 
> As vxlan_sock_hold() is not used after this patch, it was removed too.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied to net-next.
