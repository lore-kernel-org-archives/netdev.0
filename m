From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Wed, 30 Apr 2014 16:29:17 -0700
Message-ID: <1398900557.29914.187.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
	  <20140430163504.9021.12828.stgit@nitbit.x32>
	 <1398877228.29914.177.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5361785B.6000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53641 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbaD3X3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 19:29:19 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so1082540pde.12
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 16:29:18 -0700 (PDT)
In-Reply-To: <5361785B.6000604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-30 at 15:25 -0700, John Fastabend wrote:

> It looks like it except for qdisc_watchdog() which needs an
> rcu_read_lock() if I'm not mistaken/
> 
> static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
> {
> 	struct qdisc_watchdog *wd = container_of(timer, struct 		
> 						 qdisc_watchdog,
> 						 timer);
> 
> 	rcu_read_lock();
> 	qdisc_unthrottled(wd->qdisc);
> 	__netif_schedule(qdisc_root(wd->qdisc));
> 	rcu_read_unlock();
> 
> 	return HRTIMER_NORESTART;
> }
> 

Normally, HRTIMER handlers are run under softirq.

Anyway you could simply use following on your builds

CONFIG_PROVE_RCU=y
