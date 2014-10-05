From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: avoid race condition in scheduling delayed work
Date: Sat, 04 Oct 2014 20:51:28 -0400 (EDT)
Message-ID: <20141004.205128.1396970963248010476.davem@davemloft.net>
References: <1412344714-29938-1-git-send-email-joe.lawrence@stratus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: joe.lawrence@stratus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaJEAv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:51:29 -0400
In-Reply-To: <1412344714-29938-1-git-send-email-joe.lawrence@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Lawrence <joe.lawrence@stratus.com>
Date: Fri, 3 Oct 2014 09:58:34 -0400

> When team_notify_peers and team_mcast_rejoin are called, they both reset
> their respective .count_pending atomic variable. Then when the actual
> worker function is executed, the variable is atomically decremented.
> This pattern introduces a potential race condition where the
> .count_pending rolls over and the worker function keeps rescheduling
> until .count_pending decrements to zero again:
 ...
> Instead of assigning a new value to .count_pending, use atomic_add to
> tack-on the additional desired worker function invocations.
> 
> Signed-off-by: Joe Lawrence <joe.lawrence@stratus.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
> Fixes: fc423ff00df3a19554414ee ("team: add peer notification")
> Fixes: 492b200efdd20b8fcfdac87 ("team: add support for sending multicast rejoins")

Applied and queued up for -stable, thanks.
