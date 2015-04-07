From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv6: hold locks around mrt->mfc6_cache_array[]
Date: Tue, 07 Apr 2015 18:24:09 -0400 (EDT)
Message-ID: <20150407.182409.686606754359856723.davem@davemloft.net>
References: <1428362330.1872.9.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbDGWYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:24:12 -0400
In-Reply-To: <1428362330.1872.9.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams <3chas3@gmail.com>
Date: Mon, 06 Apr 2015 19:18:50 -0400

> setsocketopt() -> ip6mr_mfc_add() -> ip6mr_cache_resolved() -> ip6_mr_foward()
> needs some lock since it is going to read the cache array.

Nothing can change in the table while the RTNL mutex is held, which
these code paths have acquired.
