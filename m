From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour: fix base_reachable_time(_ms) not effective
 immediatly when changed
Date: Wed, 14 Jan 2015 00:28:41 -0500 (EST)
Message-ID: <20150114.002841.535982441503310505.davem@davemloft.net>
References: <20150113.220438.1470978767602235254.davem@davemloft.net>
	<1421205759-19766-1-git-send-email-jeff@melix.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@melix.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbANF2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 00:28:42 -0500
In-Reply-To: <1421205759-19766-1-git-send-email-jeff@melix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Francois Remy <jeff@melix.org>
Date: Wed, 14 Jan 2015 04:22:39 +0100

> When setting base_reachable_time or base_reachable_time_ms on a
> specific interface through sysctl or netlink, the reachable_time
> value is not updated.
> 
> This means that neighbour entries will continue to be updated using the
> old value until it is recomputed in neigh_period_work (which
>     recomputes the value every 300*HZ).
> On systems with HZ equal to 1000 for instance, it means 5mins before
> the change is effective.
> 
> This patch changes this behavior by recomputing reachable_time after
> each set on base_reachable_time or base_reachable_time_ms.
> The new value will become effective the next time the neighbour's timer
> is triggered.
> 
> Changes are made in two places: the netlink code for set and the sysctl
> handling code. For sysctl, I use a proc_handler. The ipv6 network
> code does provide its own handler but it already refreshes
> reachable_time correctly so it's not an issue.
> Any other user of neighbour which provide its own handlers must
> refresh reachable_time.
> 
> Signed-off-by: Jean-Francois Remy <jeff@melix.org>

Applied, thanks.
