From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: prevent dst uses after free
Date: Thu, 21 Sep 2017 20:42:48 -0700 (PDT)
Message-ID: <20170921.204248.634064806877379720.davem@davemloft.net>
References: <80e8948e-669b-4139-add6-637c6dd3405f@itcare.pl>
        <1506005799.29839.130.camel@edumazet-glaptop3.roam.corp.google.com>
        <1506010546.29839.148.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: pstaszewski@itcare.pl, weiwan@google.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdIVDmt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 23:42:49 -0400
In-Reply-To: <1506010546.29839.148.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Sep 2017 09:15:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In linux-4.13, Wei worked hard to convert dst to a traditional
> refcounted model, removing GC.
> 
> We now want to make sure a dst refcount can not transition from 0 back
> to 1.
> 
> The problem here is that input path attached a not refcounted dst to an
> skb. Then later, because packet is forwarded and hits skb_dst_force()
> before exiting RCU section, we might try to take a refcount on one dst
> that is about to be freed, if another cpu saw 1 -> 0 transition in
> dst_release() and queued the dst for freeing after one RCU grace period.
> 
> Lets unify skb_dst_force() and skb_dst_force_safe(), since we should
> always perform the complete check against dst refcount, and not assume
> it is not zero.
> 
> Bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=197005
 ...
> Similarly dst_clone() can use dst_hold() helper to have additional
> debugging, as a follow up to commit 44ebe79149ff ("net: add debug
> atomic_inc_not_zero() in dst_hold()")
> 
> In net-next we will convert dst atomic_t to refcount_t for peace of
> mind.
> 
> Fixes: a4c2fd7f7891 ("net: remove DST_NOCACHE flag")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Wei Wang <weiwan@google.com>
> Reported-by: Pawe©© Staszewski <pstaszewski@itcare.pl>
> Bisected-by: Pawe©© Staszewski <pstaszewski@itcare.pl>

Applied and queued up for -stable, thanks Eric.
