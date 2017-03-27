From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH 1/5] rds: tcp: release the created connection
Date: Mon, 27 Mar 2017 03:37:56 -0400
Message-ID: <20170327073756.GA21982@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
 <1490598390-13812-2-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        junxiao.bi@oracle.com, joe.jin@oracle.com
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:42861 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdC0Hqw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 03:46:52 -0400
Content-Disposition: inline
In-Reply-To: <1490598390-13812-2-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/27/17 03:06), Zhu Yanjun wrote:
> Date: Mon, 27 Mar 2017 03:06:26 -0400
> From: Zhu Yanjun <yanjun.zhu@oracle.com>
> To: yanjun.zhu@oracle.com, santosh.shilimkar@oracle.com,
>  netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
>  rds-devel@oss.oracle.com, junxiao.bi@oracle.com, joe.jin@oracle.com
> Subject: [PATCH 1/5] rds: tcp: release the created connection
> X-Mailer: git-send-email 2.7.4
> 
> When some error occurs, the created connection should be destroyed.

No please dont do this.

This is the case when there are duelling connections. We want
to reset the new (accept sock) and leave the old socket in place.

How did you test this? Did you test it with network namespaces?

--Sowmini


>  net/rds/tcp_listen.c | 1 +
> 
> diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
> index 5076788..58aa5bc 100644
> --- a/net/rds/tcp_listen.c
> +++ b/net/rds/tcp_listen.c
> @@ -196,6 +196,7 @@ int rds_tcp_accept_one(struct socket *sock)
>  rst_nsk:
>  	/* reset the newly returned accept sock and bail */
>  	kernel_sock_shutdown(new_sock, SHUT_RDWR);
> +	rds_conn_destroy(conn);
>  	ret = 0;
>  out:
>  	if (rs_tcp)
> -- 
> 2.7.4
> 
