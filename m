From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Tue, 22 Nov 2016 10:37:42 -0500 (EST)
Message-ID: <20161122.103742.1421376877129949203.davem@davemloft.net>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
        <20161122144844.GB1819@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roid@mellanox.com, netdev@vger.kernel.org, jiri@mellanox.com,
        xiyou.wangcong@gmail.com, ogerlitz@mellanox.com,
        cwang@twopensource.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755665AbcKVPhu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 10:37:50 -0500
In-Reply-To: <20161122144844.GB1819@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 22 Nov 2016 15:48:44 +0100

> Tue, Nov 22, 2016 at 03:25:26PM CET, roid@mellanox.com wrote:
>>tp->root is being allocated in init() time and kfreed in destroy()
>>however it is being dereferenced in classify() path.
>>
>>We could be in classify() path after destroy() was called and thus 
>>tp->root is null. Verifying if tp->root is null in classify() path 
>>is enough because it's being freed with kfree_rcu() and classify() 
>>path is under rcu_read_lock().
>>
>>Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
>>Signed-off-by: Roi Dayan <roid@mellanox.com>
>>Cc: Cong Wang <cwang@twopensource.com>
> 
> This is correct
> 
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> 
> The other way to fix this would be to move tp->ops->destroy call to
> call_rcu phase. That would require bigger changes though. net-next
> perhaps?

This patch is targetted at net-next as per Subj.
