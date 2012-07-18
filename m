From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio
 cgroup during init
Date: Wed, 18 Jul 2012 09:26:50 -0700 (PDT)
Message-ID: <20120718.092650.57631064915471411.davem@davemloft.net>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab2GRQ0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:26:51 -0400
In-Reply-To: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 17 Jul 2012 17:33:16 -0700

> When the netprio cgroup is built in the kernel cgroup_init will call
> cgrp_create which eventually calls update_netdev_tables. This is
> being called before do_initcalls() so a null ptr dereference occurs
> on init_net.
> 
> This patch adds a check on init_net.count to verify the structure
> has been initialized. The failure was introduced here,
> 
> commit ef209f15980360f6945873df3cd710c5f62f2a3e
> Author: Gao feng <gaofeng@cn.fujitsu.com>
> Date:   Wed Jul 11 21:50:15 2012 +0000
> 
>     net: cgroup: fix access the unallocated memory in netprio cgroup
> 
> Tested with ping with netprio_cgroup as a module and built in.
> 
> Marked RFC for now I think DaveM might have a reason why this needs
> some improvement.
> 
> Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

John, just so I can sleep better at night, can you add an explicit
initializer to init_net in net/core/net_namespace.c in this patch
so that "count" is explicitly set to ATOMIC_INIT(0)?

This is done elsewhere in the tree for similar situations.

Otherwise this patch looks great, thanks a lot.
