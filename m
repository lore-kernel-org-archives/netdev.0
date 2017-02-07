From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 0/7] net: dst_confirm replacement
Date: Tue, 07 Feb 2017 13:11:34 -0500 (EST)
Message-ID: <20170207.131134.567606043153504044.davem@davemloft.net>
References: <1486415657-14714-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, steffen.klassert@secunet.com,
        linux-rdma@vger.kernel.org, yuehaibing@huawei.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753961AbdBGSLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:11:36 -0500
In-Reply-To: <1486415657-14714-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon,  6 Feb 2017 23:14:10 +0200

> 	This patchset addresses the problem of neighbour
> confirmation where received replies from one nexthop
> can cause confirmation of different nexthop when using
> the same dst. Thanks to YueHaibing <yuehaibing@huawei.com>
> for tracking the dst->pending_confirm problem.

This looks good enough to apply to net-next, so I have done
so.  Thanks Julian!

> - I failed to understand the CXGB* code, I see dst_confirm()
> calls but I'm not sure dst_neigh_output() was called. For now
> I just removed the dst->pending_confirm flag and left all
> dst_confirm() calls there. Any better idea?

As I said, it is trying to confirm neighbours based upon traffic
occurring in the chips TCP offload stack.  The 'cm' in "iwch_cm.c"
means "connection manager".

We can probably get to the neigh that will end up being used
since there should be a flow key somewhere that we can use to
determine the nexthop address for neigh lookup.

> - Now may be old function neigh_output() should be restored
> instead of dst_neigh_output?

Please elaborate.

Thanks.
