From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [TRIVIAL PATCH next 15/15] net: Convert vmalloc/memset to vzalloc
Date: Thu, 02 Jun 2011 16:49:53 +0200
Message-ID: <4DE7A311.5000406@netfilter.org>
References: <cover.1306603968.git.joe@perches.com> <045996b9688bfaa2efbd8999405a67e23cd0a075.1306603968.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Andy Grover <andy.grover@oracle.com>,
	Jiri Kosina <trivial@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rds-devel@oss.oracle.com
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <045996b9688bfaa2efbd8999405a67e23cd0a075.1306603968.git.joe@perches.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Are you going to take this patch? it includes one chunck which is out of
netfilter scope.

Thanks.

On 28/05/11 19:36, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/netfilter/x_tables.c |    5 ++---
>  net/rds/ib_cm.c          |    6 ++----
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index b0869fe..71441b9 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -776,12 +776,11 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
>  
>  	size = sizeof(void **) * nr_cpu_ids;
>  	if (size > PAGE_SIZE)
> -		i->jumpstack = vmalloc(size);
> +		i->jumpstack = vzalloc(size);
>  	else
> -		i->jumpstack = kmalloc(size, GFP_KERNEL);
> +		i->jumpstack = kzalloc(size, GFP_KERNEL);
>  	if (i->jumpstack == NULL)
>  		return -ENOMEM;
> -	memset(i->jumpstack, 0, size);
>  
>  	i->stacksize *= xt_jumpstack_multiplier;
>  	size = sizeof(void *) * i->stacksize;
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index fd453dd..6ecaf78 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -374,23 +374,21 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
>  		goto out;
>  	}
>  
> -	ic->i_sends = vmalloc_node(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work),
> +	ic->i_sends = vzalloc_node(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work),
>  				   ibdev_to_node(dev));
>  	if (!ic->i_sends) {
>  		ret = -ENOMEM;
>  		rdsdebug("send allocation failed\n");
>  		goto out;
>  	}
> -	memset(ic->i_sends, 0, ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work));
>  
> -	ic->i_recvs = vmalloc_node(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work),
> +	ic->i_recvs = vzalloc_node(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work),
>  				   ibdev_to_node(dev));
>  	if (!ic->i_recvs) {
>  		ret = -ENOMEM;
>  		rdsdebug("recv allocation failed\n");
>  		goto out;
>  	}
> -	memset(ic->i_recvs, 0, ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work));
>  
>  	rds_ib_recv_init_ack(ic);
>  

