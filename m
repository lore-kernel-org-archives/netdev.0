From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 RFC net-next 0/7] net: dst_confirm replacement
Date: Mon, 30 Jan 2017 10:13:39 -0500 (EST)
Message-ID: <20170130.101339.2050288140097606206.davem@davemloft.net>
References: <1485613578-19973-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        yuehaibing@huawei.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753519AbdA3PO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:14:26 -0500
In-Reply-To: <1485613578-19973-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 28 Jan 2017 16:26:11 +0200

> 	This patchset addresses the problem of neighbour
> confirmation where received replies from one nexthop
> can cause confirmation of different nexthop when using
> the same dst. Thanks to YueHaibing <yuehaibing@huawei.com>
> for tracking the dst->pending_confirm problem.
> 
> 	Sockets can obtain cached output route. Such
> routes can be to known nexthop (rt_gateway=IP) or to be
> used simultaneously for different nexthop IPs by different
> subnet prefixes (nh->nh_scope = RT_SCOPE_HOST, rt_gateway=0).
> 
> 	At first look, there are more problems:
> 
> - dst_confirm() sets flag on dst and not on dst->path,
> as result, indication is lost when XFRM is used
> 
> - DNAT can change the nexthop, so the really used nexthop is
> not confirmed
> 
> 	So, the following solution is to avoid using
> dst->pending_confirm.

For the most part this series looks good to me, nice work.

> - I failed to understand the CXGB* code, I see dst_confirm()
> calls but I'm not sure dst_neigh_output() was called. For now
> I just removed the dst->pending_confirm flag and left all
> dst_confirm() calls there. Any better idea?

It is trying to manage the dst and neigh state for TCP connections
managed by it's offload engine.  So you will not therefore see any
actual packet output for the sessions it is performing confirmation
for.
