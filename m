From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net_sched: add 64bit rate estimators
Date: Tue, 11 Jun 2013 02:51:32 -0700 (PDT)
Message-ID: <20130611.025132.157790026336411319.davem@davemloft.net>
References: <1370408447.24311.241.camel@edumazet-glaptop>
	<1370533402.24311.353.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab3FKJvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:51:33 -0400
In-Reply-To: <1370533402.24311.353.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jun 2013 08:43:22 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> struct gnet_stats_rate_est contains u32 fields, so the bytes per second
> field can wrap at 34360Mbit.
> 
> Add a new gnet_stats_rate_est64 structure to get 64bit bps/pps fields,
> and switch the kernel to use this structure natively.
> 
> This structure is dumped to user space as a new attribute :
> 
> TCA_STATS_RATE_EST64
> 
> Old tc command will now display the capped bps (to 34360Mbit), instead
> of wrapped values, and updated tc command will display correct
> information.
> 
> Old tc command output, after patch :
> 
> eric:~# tc -s -d qd sh dev lo
> qdisc pfifo 8001: root refcnt 2 limit 1000p
>  Sent 80868245400 bytes 1978837 pkt (dropped 0, overlimits 0 requeues 0) 
>  rate 34360Mbit 189696pps backlog 0b 0p requeues 0 
> 
> This patch carefully reorganizes "struct Qdisc" layout to get optimal
> performance on SMP.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Eric.
