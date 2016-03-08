From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] ipv6: per netns FIB6 walkers and
 garbage collector
Date: Tue, 08 Mar 2016 15:17:13 -0500 (EST)
Message-ID: <20160308.151713.644429771194150736.davem@davemloft.net>
References: <cover.1457443526.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hannes@stressinduktion.org, kafai@fb.com,
	xiyou.wangcong@gmail.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbcCHURR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:17:17 -0500
In-Reply-To: <cover.1457443526.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue,  8 Mar 2016 14:44:15 +0100 (CET)

> Commit 2ac3ac8f86f2 ("ipv6: prevent fib6_run_gc() contention") reduced
> the risk of contention on FIB6 garbage collector lock on systems with
> many CPUs. However, one of our customers can still observe heavy
> contention on fib6_gc_lock which can even trigger the soft lockup
> detector.
> 
> This is caused by garbage collector running in forced mode from a timer.
> While there is one timer per network namespace, the instances of
> fib6_run_gc() running from them are protected by one global spinlock so
> that only one garbage collector can run at any moment and other
> namespaces have to wait. As most relevant data structures are separated
> per netns, there is little reason for garbage collectors blocking each
> other.
> 
> Similar problem exists for walkers: changes in one tree do not need to
> adjust (and block) walkers traversing FIB trees in other namespaces.
> 
> This series separates both the walkers infrastructure and garbage
> collector so that they work independently in network namespaces.
> 
> v2: get rid of ifdef in ipv6_route_seq_setup_walk(), pass net from
> callers instead

Series applied, thanks.
