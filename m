From: Andy Grover <andy.grover@oracle.com>
Subject: Re: rds: use kmem_cache_zalloc instead of kmem_cache_alloc/memset
Date: Thu, 09 Apr 2009 10:43:13 -0700
Message-ID: <49DE33B1.4010700@oracle.com>
References: <49DDAB8A.5000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36064 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757213AbZDIRn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 13:43:28 -0400
In-Reply-To: <49DDAB8A.5000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
> Use kmem_cache_zalloc instead of kmem_cache_alloc/memset.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/rds/connection.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/net/rds/connection.c b/net/rds/connection.c
> index 273f064..d14445c 100644
> --- a/net/rds/connection.c
> +++ b/net/rds/connection.c
> @@ -148,14 +148,12 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
>  	if (conn)
>  		goto out;
>  
> -	conn = kmem_cache_alloc(rds_conn_slab, gfp);
> +	conn = kmem_cache_zalloc(rds_conn_slab, gfp);
>  	if (conn == NULL) {
>  		conn = ERR_PTR(-ENOMEM);
>  		goto out;
>  	}
>  
> -	memset(conn, 0, sizeof(*conn));
> -
>  	INIT_HLIST_NODE(&conn->c_hash_node);
>  	conn->c_version = RDS_PROTOCOL_3_0;
>  	conn->c_laddr = laddr;

Thanks, will include in next rds updates!

Regards -- Andy
