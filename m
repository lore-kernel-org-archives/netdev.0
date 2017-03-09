From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 1/5] rds: ib: drop unnecessary rdma_reject
Date: Thu, 9 Mar 2017 08:47:33 -0800
Message-ID: <91fd8533-20ef-555b-f8cf-deeeef946e59@oracle.com>
References: <1489044405-26150-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34757 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754730AbdCIQtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 11:49:08 -0500
In-Reply-To: <1489044405-26150-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/8/2017 11:26 PM, Zhu Yanjun wrote:
> When rdma_accept fails, rdma_reject is called in it. As such, it is
> not necessary to execute rdma_reject again.
>
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  net/rds/ib_cm.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index ce3775a..eca3d5f 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -677,8 +677,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>  		event->param.conn.initiator_depth);
>
>  	/* rdma_accept() calls rdma_reject() internally if it fails */
> -	err = rdma_accept(cm_id, &conn_param);
> -	if (err)
> +	if (rdma_accept(cm_id, &conn_param))
>  		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
>
There are couple of consumer reject reasons needs to be conveyed.
Current code don't pass them, but downstream code has them and
hence I kept the code as is. Its good to avoid the reject on
current code so am fine with the change.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
