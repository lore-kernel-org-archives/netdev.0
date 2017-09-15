From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix an use-after-free issue in sctp_sock_dump
Date: Fri, 15 Sep 2017 14:48:44 -0700 (PDT)
Message-ID: <20170915.144844.2163359752292953670.davem@davemloft.net>
References: <9de7bef8f4f8c0f369361118f6d2daee5d188467.1505444541.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com, pabeni@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdIOVsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:48:45 -0400
In-Reply-To: <9de7bef8f4f8c0f369361118f6d2daee5d188467.1505444541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 15 Sep 2017 11:02:21 +0800

> Commit 86fdb3448cc1 ("sctp: ensure ep is not destroyed before doing the
> dump") tried to fix an use-after-free issue by checking !sctp_sk(sk)->ep
> with holding sock and sock lock.
> 
> But Paolo noticed that endpoint could be destroyed in sctp_rcv without
> sock lock protection. It means the use-after-free issue still could be
> triggered when sctp_rcv put and destroy ep after sctp_sock_dump checks
> !ep, although it's pretty hard to reproduce.
> 
> I could reproduce it by mdelay in sctp_rcv while msleep in sctp_close
> and sctp_sock_dump long time.
> 
> This patch is to add another param cb_done to sctp_for_each_transport
> and dump ep->assocs with holding tsp after jumping out of transport's
> traversal in it to avoid this issue.
> 
> It can also improve sctp diag dump to make it run faster, as no need
> to save sk into cb->args[5] and keep calling sctp_for_each_transport
> any more.
> 
> This patch is also to use int * instead of int for the pos argument
> in sctp_for_each_transport, which could make postion increment only
> in sctp_for_each_transport and no need to keep changing cb->args[2]
> in sctp_sock_filter and sctp_sock_dump any more.
> 
> Fixes: 86fdb3448cc1 ("sctp: ensure ep is not destroyed before doing the dump")
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
