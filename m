From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] net: check dead netns for peernet2id_alloc()
Date: Thu, 17 Nov 2016 09:39:33 +0100
Message-ID: <60db3c1e-3697-91c5-2272-eb13c257e09d@6wind.com>
References: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: avagin@gmail.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35972 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbcKQIjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 03:39:36 -0500
Received: by mail-wm0-f52.google.com with SMTP id g23so295350754wme.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 00:39:35 -0800 (PST)
In-Reply-To: <1479320822-17483-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2016 à 19:27, Cong Wang a écrit :
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
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
