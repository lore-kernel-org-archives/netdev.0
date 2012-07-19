From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 08:52:29 -0700 (PDT)
Message-ID: <20120719.085229.2014129813204637207.davem@davemloft.net>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab2GSPwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:52:30 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E5D2858447E
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 08:52:31 -0700 (PDT)
In-Reply-To: <20120718.112404.1910372180742347127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In a dream I found a bug in this patch and the next one.

When we fetch a cached route from the FIB info, we have to
check if it has been invalidated by a PMTU event or similar.
And if so, cmpxchg() it with NULL and release it, so we
can build and install a new cached route there.

I'll fix this up when I integrate everyone's feedback later
today.
