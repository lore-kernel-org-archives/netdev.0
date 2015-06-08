From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 15:05:18 -0700 (PDT)
Message-ID: <20150608.150518.424856528462798668.davem@davemloft.net>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	<87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
	<1433793517.4616.4.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbbFHWFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:05:21 -0400
In-Reply-To: <1433793517.4616.4.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 08 Jun 2015 21:58:37 +0200

> +static inline u32 ipv4_idev_rt_table(const struct net_device *dev)
> +{
> +       u32 table_id;
> +
> +       rcu_read_lock();
> +       table_id = __in_dev_get_rcu(dev)->rt_table_id;
> +       rcu_read_unlock();
> +
> +       return table_id != RT_TABLE_UNSPEC ? table_id : RT_TABLE_LOCAL;
> +}

It's a real shame you have to do all of this RCU locking and inetdev
deref, because in more than half of the call sites the idev is already
available.
