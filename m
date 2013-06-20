From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] htb: refactor struct htb_sched fields for
 performance
Date: Wed, 19 Jun 2013 23:07:42 -0700 (PDT)
Message-ID: <20130619.230742.1951790912113794085.davem@davemloft.net>
References: <1371292210.3252.159.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797Ab3FTGHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 02:07:43 -0400
In-Reply-To: <1371292210.3252.159.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 15 Jun 2013 03:30:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> htb_sched structures are big, and source of false sharing on SMP.
> 
> Every time a packet is queued or dequeue, many cache lines must be
> touched because structures are not lay out properly.
> 
> By carefully splitting htb_sched in two parts, and define sub structures
> to increase data locality, we can improve performance dramatically on
> SMP.
> 
> New htb_prio structure can also be used in htb_class to increase data
> locality.
> 
> I got 26 % performance increase on a 24 threads machine, with 200
> concurrent netperf in TCP_RR mode, using a HTB hierarchy of 4 classes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
