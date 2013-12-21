From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rds: prevent dereference of a NULL device in rds_iw_laddr_check
Date: Sat, 21 Dec 2013 03:31:07 +0300
Message-ID: <52B4E14B.6080208@cogentembedded.com>
References: <1387581520-10272-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>,
	venkat.x.venkatsubra@oracle.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387581520-10272-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/21/2013 02:18 AM, Sasha Levin wrote:

> Binding might result in a NULL device which is later dereferenced
> without checking.

> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   net/rds/iw.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)

> diff --git a/net/rds/iw.c b/net/rds/iw.c
> index 7826d46..0298920 100644
> --- a/net/rds/iw.c
> +++ b/net/rds/iw.c
> @@ -239,7 +239,8 @@ static int rds_iw_laddr_check(__be32 addr)
>   	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&sin);
>   	/* due to this, we will claim to support IB devices unless we
>   	   check node_type. */
> -	if (ret || cm_id->device->node_type != RDMA_NODE_RNIC)
> +	if (ret || !cm_id->device ||
> +            cm_id->device->node_type != RDMA_NODE_RNIC)

    Indent with tabs and then spaces, not with spaces only please, so that the 
line aligns under 'ret'.

WBR, Sergei
