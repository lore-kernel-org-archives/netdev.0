From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] tcp: Remove unnecessary dst check in
 tcp_conn_request.
Date: Sat, 19 Aug 2017 21:25:24 -0700 (PDT)
Message-ID: <20170819.212524.1982304186024322688.davem@davemloft.net>
References: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
        <1502938966-6345-2-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750985AbdHTEZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 00:25:29 -0400
In-Reply-To: <1502938966-6345-2-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Wed, 16 Aug 2017 20:02:45 -0700

> Because we remove the tcp_tw_recycle support in the commit
> 4396e46187c ('tcp: remove tcp_tw_recycle') and also delete
> the code 'af_ops->route_req' for sysctl_tw_recycle in tcp_conn_request.
> Now when we call the 'af_ops->route_req', the dist always is
> NULL, and we remove the unnecessay check.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>

This is a bug actually, rather than something to paper over
by removing the check.

Code earlier in this function needs a proper 'dst' in order to operate
properly.

There is a call to tcp_peer_is_proven() which must have a proper route
to make the determination yet it will always be NULL.

Please investigate what the code is doing and how a test became
"unnecessary" over time before blindly removing it, thank you.
