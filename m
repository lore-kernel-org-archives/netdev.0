From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_tbf: handle too small burst
Date: Sat, 23 Nov 2013 14:49:33 -0800 (PST)
Message-ID: <20131123.144933.671852794341688223.davem@davemloft.net>
References: <5290628F.6080604@huawei.com>
	<1385229367.10637.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<1385240360.10637.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org,
	ben@decadent.org.uk, jpirko@redhat.com, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089Ab3KWWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:41:03 -0500
In-Reply-To: <1385240360.10637.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Nov 2013 12:59:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> If a too small burst is inadvertently set on TBF, we might trigger
> a bug in tbf_segment(), as 'skb' instead of 'segs' was used in a
> qdisc_reshape_fail() call.
> 
> tc qdisc add dev eth0 root handle 1: tbf latency 50ms burst 1KB rate
> 50mbit
> 
> Fix the bug, and add a warning, as such configuration is not
> going to work anyway for non GSO packets.
> 
> (For some reason, one has to use a burst >= 1520 to get a working
> configuration, even with old kernels. This is a probable iproute2/tc
> bug)
> 
> Based on a report and initial patch from Yang Yingliang
> 
> Fixes: e43ac79a4bc6 ("sch_tbf: segment too big GSO packets")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yang Yingliang <yangyingliang@huawei.com>

Applied and queued up for -stable.
