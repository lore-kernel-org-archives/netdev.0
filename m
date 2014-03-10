From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: add cond_resched() to class and
 qdisc dump
Date: Mon, 10 Mar 2014 15:32:05 -0400 (EDT)
Message-ID: <20140310.153205.851677230247140352.davem@davemloft.net>
References: <1394244064.20149.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbaCJTcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:32:07 -0400
In-Reply-To: <1394244064.20149.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Mar 2014 18:01:04 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We have seen delays of more than 50ms in class or qdisc dumps, in case
> device is under high TX stress.
> 
> Add cond_resched() to give a chance to higher prio tasks to get cpu.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Is it OK to sleep (or rather: cond_resched()) in an RCU region?
That's what will potentially happen via tc_dump_qdisc() it seems.
