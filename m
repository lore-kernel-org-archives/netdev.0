From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: RTA_PREFSRC dumping was somewhat incorrect.
Date: Tue, 05 May 2015 16:56:11 -0400 (EDT)
Message-ID: <20150505.165611.154775063868987954.davem@davemloft.net>
References: <BAADD2CA-4AC1-4916-B035-246F3CBF080B@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: markus.stenberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728AbbEEU4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 16:56:12 -0400
In-Reply-To: <BAADD2CA-4AC1-4916-B035-246F3CBF080B@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Stenberg <markus.stenberg@iki.fi>
Date: Mon, 4 May 2015 14:46:02 +0300

> Avoid dumping RTA_PREFSRC twice if iif is not set, but dst is.
> 
> Note that the change also dumps RTA_PREFSRC even if iif RTA_IIF is
> sent. As scopes are not that rare in IPv6, I believe that to be
> correct behavior.
> 
> Signed-off-by: Markus Stenberg <markus.stenberg@iki.fi>

The distinguishing characteristic that should decide whether we
provide a PREFSRC or not is whether this route is an output route
or not.

Neither the current logic, nor your patch, implements this.

But that's what this code needs to do.
