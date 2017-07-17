From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds: cancel send/recv work before queuing
 connection shutdown
Date: Sun, 16 Jul 2017 19:07:46 -0700 (PDT)
Message-ID: <20170716.190746.619711541077075506.davem@davemloft.net>
References: <1500248626-80602-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
        santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdGQCHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 22:07:51 -0400
In-Reply-To: <1500248626-80602-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sun, 16 Jul 2017 16:43:46 -0700

> We could end up executing rds_conn_shutdown before the rds_recv_worker
> thread, then rds_conn_shutdown -> rds_tcp_conn_shutdown can do a
> sock_release and set sock->sk to null, which may interleave in bad
> ways with rds_recv_worker, e.g., it could result in:
> 
> "BUG: unable to handle kernel NULL pointer dereference at 0000000000000078"
>     [ffff881769f6fd70] release_sock at ffffffff815f337b
>     [ffff881769f6fd90] rds_tcp_recv at ffffffffa043c888 [rds_tcp]
>     [ffff881769f6fdb0] rds_recv_worker at ffffffffa04a4810 [rds]
>     [ffff881769f6fde0] process_one_work at ffffffff810a14c1
>     [ffff881769f6fe40] worker_thread at ffffffff810a1940
>     [ffff881769f6fec0] kthread at ffffffff810a6b1e
> 
> Also, do not enqueue any new shutdown workq items when the connection is
> shutting down (this may happen for rds-tcp in softirq mode, if a FIN
> or CLOSE is received while the modules is in the middle of an unload)
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thank you.
