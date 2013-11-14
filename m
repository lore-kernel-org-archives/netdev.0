From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Thu, 14 Nov 2013 16:26:06 -0500 (EST)
Message-ID: <20131114.162606.1037335356168882336.davem@davemloft.net>
References: <87y54u59zq.fsf@natisbad.org>
	<1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
	<1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arno@natisbad.org, sujith@msujith.org, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, nbd@openwrt.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab3KNV0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:26:09 -0500
In-Reply-To: <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Nov 2013 06:32:54 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit c9eeec26e32e ("tcp: TSQ can use a dynamic limit"), several
> users reported throughput regressions, notably on mvneta and wifi
> adapters.
> 
> 802.11 AMPDU requires a fair amount of queueing to be effective.
> 
> This patch partially reverts the change done in tcp_write_xmit()
> so that the minimal amount is sysctl_tcp_limit_output_bytes.
> 
> It also remove the use of this sysctl while building skb stored
> in write queue, as TSO autosizing does the right thing anyway.
> 
> Users with well behaving NICS and correct qdisc (like sch_fq),
> can then lower the default sysctl_tcp_limit_output_bytes value from
> 128KB to 8KB.
> 
> This new usage of sysctl_tcp_limit_output_bytes permits each driver
> authors to check how their driver performs when/if the value is set
> to a minimum of 4KB.
> 
> Normally, line rate for a single TCP flow should be possible, 
> but some drivers rely on timers to perform TX completion and
> too long TX completion delays prevent reaching full throughput.
> 
> Fixes: c9eeec26e32e ("tcp: TSQ can use a dynamic limit")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Sujith Manoharan <sujith@msujith.org>
> Reported-by: Arnaud Ebalard <arno@natisbad.org>
> Tested-by: Sujith Manoharan <sujith@msujith.org>

Applied and queued up for -stable, thanks Eric.
