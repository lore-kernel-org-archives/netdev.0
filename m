From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix a memleak that dccp_ipv6 doesn't put
 reqsk properly
Date: Thu, 27 Jul 2017 00:01:22 -0700 (PDT)
Message-ID: <20170727.000122.1772066009028441614.davem@davemloft.net>
References: <17b2008535695e5885775418a31ee74f3ca704f5.1501049949.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdG0HBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:01:23 -0400
In-Reply-To: <17b2008535695e5885775418a31ee74f3ca704f5.1501049949.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 26 Jul 2017 14:19:09 +0800

> In dccp_v6_conn_request, after reqsk gets alloced and hashed into
> ehash table, reqsk's refcnt is set 3. one is for req->rsk_timer,
> one is for hlist, and the other one is for current using.
> 
> The problem is when dccp_v6_conn_request returns and finishes using
> reqsk, it doesn't put reqsk. This will cause reqsk refcnt leaks and
> reqsk obj never gets freed.
> 
> Jianlin found this issue when running dccp_memleak.c in a loop, the
> system memory would run out.
> 
> dccp_memleak.c:
>   int s1 = socket(PF_INET6, 6, IPPROTO_IP);
>   bind(s1, &sa1, 0x20);
>   listen(s1, 0x9);
>   int s2 = socket(PF_INET6, 6, IPPROTO_IP);
>   connect(s2, &sa1, 0x20);
>   close(s1);
>   close(s2);
> 
> This patch is to put the reqsk before dccp_v6_conn_request returns,
> just as what tcp_conn_request does.
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
