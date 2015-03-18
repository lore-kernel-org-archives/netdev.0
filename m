From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bnx2x: Fix statistics locking scheme
Date: Wed, 18 Mar 2015 15:10:59 -0400 (EDT)
Message-ID: <20150318.151059.979411313448939306.davem@davemloft.net>
References: <1426688042-20315-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194AbbCRTLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 15:11:03 -0400
In-Reply-To: <1426688042-20315-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 18 Mar 2015 16:14:02 +0200

> +int bnx2x_stats_safe_exec(struct bnx2x *bp,
> +			  void (func_to_exec)(void *cookie),
> +			  void *cookie)
 ...
> +	if (bp->stats_pending) {
> +		BNX2X_ERR("Failed to wait for stats pending to clear\n");
> +		return -EBUSY;

Buggy, this returns with the stats_lock still held.

In my humble opinion, you are putting very little care and effort into
this bug fix.

Also I disagree with your timeout logic.

I suspect that the real reason these timeouts are present, is that
the locking hierarchy is uncertain.

Nothing really should create the situation those trylocks seem to
be dealing with.
