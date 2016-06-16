From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Don't forget pr_fmt on net_dbg_ratelimited for
 CONFIG_DYNAMIC_DEBUG
Date: Wed, 15 Jun 2016 22:08:20 -0700 (PDT)
Message-ID: <20160615.220820.479300229365061457.davem@davemloft.net>
References: <20160615091453.29609-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tbingham@akamai.com
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbcFPFIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:08:21 -0400
In-Reply-To: <20160615091453.29609-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Wed, 15 Jun 2016 11:14:53 +0200

> The implementation of net_dbg_ratelimited in the CONFIG_DYNAMIC_DEBUG
> case was added with 2c94b5373 ("net: Implement net_dbg_ratelimited() for
> CONFIG_DYNAMIC_DEBUG case"). The implementation strategy was to take the
> usual definition of the dynamic_pr_debug macro, but alter it by adding a
> call to "net_ratelimit()" in the if statement. This is, in fact, the
> correct approach.
> 
> However, while doing this, the author of the commit forgot to surround
> fmt by pr_fmt, resulting in unprefixed log messages appearing in the
> console. So, this commit adds back the pr_fmt(fmt) invocation, making
> net_dbg_ratelimited properly consistent across DEBUG, no DEBUG, and
> DYNAMIC_DEBUG cases, and bringing parity with the behavior of
> dynamic_pr_debug as well.
> 
> Fixes: 2c94b5373 ("net: Implement net_dbg_ratelimited() for CONFIG_DYNAMIC_DEBUG case")
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Tim Bingham <tbingham@akamai.com>

Looks good, applied, thanks.
