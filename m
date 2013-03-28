From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 11:49:37 -0700
Message-ID: <1364496577.15753.51.camel@edumazet-glaptop>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
	 <1364478265.15753.42.camel@edumazet-glaptop>
	 <20130328182356.GE3337@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Balakumaran Kannan <kumaran.4353@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35153 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320Ab3C1Stj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:49:39 -0400
Received: by mail-pd0-f181.google.com with SMTP id q10so4205802pdj.12
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 11:49:39 -0700 (PDT)
In-Reply-To: <20130328182356.GE3337@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 11:23 -0700, Paul E. McKenney wrote:

> 
> Agreed, there is no point in using RCU when it is not needed.
> 
> That said...
> 
> Since v3.1, in CONFIG_PREEMPT=y kernels, rcu_read_lock() does not
> disable preemption.  In CONFIG_PREEMPT=n kernels, rcu_read_lock() does
> disable preemption, but to no effect because preemption is already
> disabled anyway.
> 
> The net effect is that rcu_read_lock() has no effect on preemption.
> 

Good point, but this patch might be a stable candidate.

Rule of thumb for networking is 

1) Control path : RTNL mutex

2) Data path : RTNL cant be taken (from softirq), so use RCU if
possible.

Thanks !
