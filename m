From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 06:44:25 -0700
Message-ID: <1364478265.15753.42.camel@edumazet-glaptop>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:48839 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629Ab3C1No2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:44:28 -0400
Received: by mail-pd0-f180.google.com with SMTP id g10so4119700pdj.39
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:44:27 -0700 (PDT)
In-Reply-To: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 18:57 +0530, Balakumaran Kannan wrote:
> IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
> interface. After down-up, routes of other interface's IPv6 addresses through
> 'lo' are lost.
> 

>  	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
> +
> +	/* Add routes to other interface's IPv6 addresses */
> +	rcu_read_lock();
> +	for_each_netdev_rcu(dev_net(dev), sp_dev) {
> +

We hold RTNL at this point, so why use RCU at all, and adding potential
long latencies ?

Just use for_each_netdev()

This way, a preemption is still allowed.

Also, I am not sure we need ipv6_find_idev()

__in6_dev_get() should be OK.
