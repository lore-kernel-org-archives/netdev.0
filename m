From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix the issue sctp_diag uses lock_sock in
 rcu_read_lock
Date: Fri, 30 Sep 2016 02:09:18 -0400 (EDT)
Message-ID: <20160930.020918.1265470401276676920.davem@davemloft.net>
References: <bd1a86ba935ffa02392b6c1271e7c06433967856.1475088944.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935528AbcI3GJY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 02:09:24 -0400
In-Reply-To: <bd1a86ba935ffa02392b6c1271e7c06433967856.1475088944.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 29 Sep 2016 02:55:44 +0800

> When sctp dumps all the ep->assocs, it needs to lock_sock first,
> but now it locks sock in rcu_read_lock, and lock_sock may sleep,
> which would break rcu_read_lock.
> 
> This patch is to get and hold one sock when traversing the list.
> After that and get out of rcu_read_lock, lock and dump it. Then
> it will traverse the list again to get the next one until all
> sctp socks are dumped.
> 
> For sctp_diag_dump_one, it fixes this issue by holding asoc and
> moving cb() out of rcu_read_lock in sctp_transport_lookup_process.
> 
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
