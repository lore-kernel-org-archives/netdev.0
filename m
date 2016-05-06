From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: fix old ioctl unlocked net device walk
Date: Thu, 05 May 2016 23:33:22 -0400 (EDT)
Message-ID: <20160505.233322.2284182158683953456.davem@davemloft.net>
References: <1462371525-26786-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbcEFDdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 23:33:24 -0400
In-Reply-To: <1462371525-26786-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed,  4 May 2016 16:18:45 +0200

> get_bridge_ifindices() is used from the old "deviceless" bridge ioctl
> calls which aren't called with rtnl held. The comment above says that it is
> called with rtnl but that is not really the case.
> Here's a sample output from a test ASSERT_RTNL() which I put in
> get_bridge_ifindices and executed "brctl show":
 ...
> Since it only reads bridge ifindices, we can use rcu to safely walk the net
> device list. Also remove the wrong rtnl comment above.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> AFAICT this has been present since the beginning of git history thus no
> fixes tag.

Applied and queued up for -stable, thanks.
