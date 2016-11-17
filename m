From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: check dead netns for peernet2id_alloc()
Date: Thu, 17 Nov 2016 11:20:44 -0500 (EST)
Message-ID: <20161117.112044.762566639692257396.davem@davemloft.net>
References: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@gmail.com, nicolas.dichtel@6wind.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39652 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbcKQQ47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 11:56:59 -0500
In-Reply-To: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Nov 2016 10:27:02 -0800

> Andrei reports we still allocate netns ID from idr after we destroy
> it in cleanup_net().
> 
> cleanup_net():
>   ...
>   idr_destroy(&net->netns_ids);
>   ...
>   list_for_each_entry_reverse(ops, &pernet_list, list)
>     ops_exit_list(ops, &net_exit_list);
>       -> rollback_registered_many()
>         -> rtmsg_ifinfo_build_skb()
>          -> rtnl_fill_ifinfo()
>            -> peernet2id_alloc()
> 
> After that point we should not even access net->netns_ids, we
> should check the death of the current netns as early as we can in
> peernet2id_alloc().
> 
> For net-next we can consider to avoid sending rtmsg totally,
> it is a good optimization for netns teardown path.
> 
> Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
