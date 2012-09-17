From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Take care of xfrm policy when checking
 dst entries
Date: Mon, 17 Sep 2012 12:49:53 -0400 (EDT)
Message-ID: <20120917.124953.1599275868994343219.davem@davemloft.net>
References: <504DFF90.3010802@6wind.com>
	<1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, eric.dumazet@gmail.com, sds@tycho.nsa.gov,
	james.l.morris@oracle.com, eparis@parisplace.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356Ab2IQQt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:49:56 -0400
In-Reply-To: <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 11 Sep 2012 10:09:43 +0200

> The goal of these patches is to fix the following problem: a session is
> established (TCP, SCTP) and after a new policy is inserted. The current
> code does not recalculate the route, thus the traffic is not encrypted.
> 
> The patch propose to check flow_cache_genid value when checking a dst
> entry, which is incremented each time a policy is inserted or deleted.
> 
> v2: use net->ipv4.rt_genid instead of flow_cache_genid (and thus save a test
>     in fast path). Also move it to net->rt_genid, to be able to use it for IPv6
>     too. Note that IPv6 will have one more test in fast path.
> 
> v3: remove unrelated "#ifdef CONFIG_XFRM" in IPv6 part
>     bump rt_genid in selinux code (same place than flow_cache_genid)
> 
> Patches are tested with TCP and SCTP, IPv4 and IPv6.

These patches don't apply cleanly at all.

In the net/ipv4/route.c code we don't initialize the genid to zero,
we stick a random value there.

And we don't increment it by one on flushes, instead we increment
it by a random amount.

I wonder what tree these were even against, the differences were
so great.
