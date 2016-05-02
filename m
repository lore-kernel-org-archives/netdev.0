From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Implement net_dbg_ratelimited() for
 CONFIG_DYNAMIC_DEBUG case
Date: Sun, 01 May 2016 21:49:34 -0400 (EDT)
Message-ID: <20160501.214934.2250379996423526821.davem@davemloft.net>
References: <1461951023-14311-1-git-send-email-tbingham@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason@zx2c4.com
To: tbingham@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbcEBBtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 21:49:41 -0400
In-Reply-To: <1461951023-14311-1-git-send-email-tbingham@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Bingham <tbingham@akamai.com>
Date: Fri, 29 Apr 2016 13:30:23 -0400

> Prior to commit d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op
> when !DEBUG") the implementation of net_dbg_ratelimited() was buggy
> for both the DEBUG and CONFIG_DYNAMIC_DEBUG cases.
> 
> The bug was that net_ratelimit() was being called and, despite
> returning true, nothing was being printed to the console. This
> resulted in messages like the following -
> 
> "net_ratelimit: %d callbacks suppressed"
> 
> with no other output nearby.
> 
> After commit d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op when
> !DEBUG") the bug is fixed for the DEBUG case. However, there's no
> output at all for CONFIG_DYNAMIC_DEBUG case.
> 
> This patch restores debug output (if enabled) for the
> CONFIG_DYNAMIC_DEBUG case.
> 
> Add a definition of net_dbg_ratelimited() for the CONFIG_DYNAMIC_DEBUG
> case. The implementation takes care to check that dynamic debugging is
> enabled before calling net_ratelimit().
> 
> Fixes: d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op when !DEBUG")
> Signed-off-by: Tim Bingham <tbingham@akamai.com>

Looks good, applied and queued up for -stable, thanks.
