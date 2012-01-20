From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: fix undo after RTO for BIC
Date: Fri, 20 Jan 2012 14:18:26 -0500 (EST)
Message-ID: <20120120.141826.1023767655731209208.davem@davemloft.net>
References: <1326944879-22780-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, hkchu@google.com,
	therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab2ATTSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 14:18:40 -0500
In-Reply-To: <1326944879-22780-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 18 Jan 2012 22:47:58 -0500

> This patch fixes BIC so that cwnd reductions made during RTOs can be
> undone (just as they already can be undone when using the default/Reno
> behavior).
> 
> When undoing cwnd reductions, BIC-derived congestion control modules
> were restoring the cwnd from last_max_cwnd. There were two problems
> with using last_max_cwnd to restore a cwnd during undo:
> 
> (a) last_max_cwnd was set to 0 on state transitions into TCP_CA_Loss
> (by calling the module's reset() functions), so cwnd reductions from
> RTOs could not be undone.
> 
> (b) when fast_covergence is enabled (which it is by default)
> last_max_cwnd does not actually hold the value of snd_cwnd before the
> loss; instead, it holds a scaled-down version of snd_cwnd.
> 
> This patch makes the following changes:
> 
> (1) upon undo, revert snd_cwnd to ca->loss_cwnd, which is already, as
> the existing comment notes, the "congestion window at last loss"
> 
> (2) stop forgetting ca->loss_cwnd on TCP_CA_Loss events
> 
> (3) use ca->last_max_cwnd to check if we're in slow start
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
