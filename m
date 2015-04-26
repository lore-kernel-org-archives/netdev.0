From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: rfs: fix crash in get_rps_cpus()
Date: Sun, 26 Apr 2015 16:09:10 -0400 (EDT)
Message-ID: <20150426.160910.281303860512321258.davem@davemloft.net>
References: <1429979724.22254.172.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, ben@decadent.org.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbbDZUJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 16:09:11 -0400
In-Reply-To: <1429979724.22254.172.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 25 Apr 2015 09:35:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 567e4b79731c ("net: rfs: add hash collision detection") had one
> mistake :
> 
> RPS_NO_CPU is no longer the marker for invalid cpu in set_rps_cpu()
> and get_rps_cpu(), as @next_cpu was the result of an AND with
> rps_cpu_mask
> 
> This bug showed up on a host with 72 cpus :
> next_cpu was 0x7f, and the code was trying to access percpu data of an
> non existent cpu.
> 
> In a follow up patch, we might get rid of compares against nr_cpu_ids,
> if we init the tables with 0. This is silly to test for a very unlikely
> condition that exists only shortly after table initialization, as
> we got rid of rps_reset_sock_flow() and similar functions that were
> writing this RPS_NO_CPU magic value at flow dismantle : When table is
> old enough, it never contains this value anymore.
> 
> Fixes: 567e4b79731c ("net: rfs: add hash collision detection")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for 4.0-stable, thanks Eric.
