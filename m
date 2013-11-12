From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: [PATCH] tcp: tsq: restore minimal amount of queueing
Date: Tue, 12 Nov 2013 20:54:33 +0530
Message-ID: <21122.18481.785917.621199@gargle.gargle.HOWL>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	<87y54u59zq.fsf@natisbad.org>
	<1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:40029 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3KLP3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 10:29:12 -0500
In-Reply-To: <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
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
> The new usage of sysctl_tcp_limit_output_bytes permits each driver
> author to check how driver performs when/if the value is set
> to a minimum of 4KB :
> 
> Normally, line rate for a single TCP flow should be possible, 
> but some drivers rely on timers to perform TX completion and
> too long delays prevent reaching full throughput.

I tested the patch with ath9k and performance with a 2-stream card is normal
again, about 195 Mbps in open air.

Thanks for the fix !

Also, I think this needs to be marked as a stable candidate, since 3.12 needs
this fix.

Sujith
