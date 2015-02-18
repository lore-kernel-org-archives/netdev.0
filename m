From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] netfilter: Remove uses of return value of
 seq_printf/puts/putc
Date: Tue, 17 Feb 2015 17:19:00 -0800
Message-ID: <1424222340.25416.19.camel@perches.com>
References: <1424136309.8287.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424136309.8287.8.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-16 at 17:25 -0800, Joe Perches wrote:
> These functions are soon going to return void so remove the
> return value uses.
> 
> Convert the return value to test seq_has_overflowed() instead.

Please do not apply.
These need conversions not to "return seq_has_
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |  4 +++-
>  net/netfilter/nf_conntrack_acct.c                     |  8 +++++---
>  net/netfilter/nf_conntrack_expect.c                   |  4 +++-
>  net/netfilter/nfnetlink_log.c                         | 12 +++++++-----
>  4 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> index a460a87..b03b801 100644
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> @@ -300,7 +300,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
>  		    __nf_ct_l3proto_find(exp->tuple.src.l3num),
>  		    __nf_ct_l4proto_find(exp->tuple.src.l3num,
>  					 exp->tuple.dst.protonum));
> -	return seq_putc(s, '\n');
> +	seq_putc(s, '\n');
> +
> +	return seq_has_overflowed(s);
>  }
>  
>  static const struct seq_operations exp_seq_ops = {
> diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
> index a4b5e2a..4d291dc 100644
> --- a/net/netfilter/nf_conntrack_acct.c
> +++ b/net/netfilter/nf_conntrack_acct.c
> @@ -47,9 +47,11 @@ seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
>  		return 0;
>  
>  	counter = acct->counter;
> -	return seq_printf(s, "packets=%llu bytes=%llu ",
> -			  (unsigned long long)atomic64_read(&counter[dir].packets),
> -			  (unsigned long long)atomic64_read(&counter[dir].bytes));
> +	seq_printf(s, "packets=%llu bytes=%llu ",
> +		   (unsigned long long)atomic64_read(&counter[dir].packets),
> +		   (unsigned long long)atomic64_read(&counter[dir].bytes));
> +
> +	return seq_has_overflowed(s);
>  };
>  EXPORT_SYMBOL_GPL(seq_print_acct);
>  
> diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
> index 91a1837..1abf92f 100644
> --- a/net/netfilter/nf_conntrack_expect.c
> +++ b/net/netfilter/nf_conntrack_expect.c
> @@ -561,7 +561,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
>  				   helper->expect_policy[expect->class].name);
>  	}
>  
> -	return seq_putc(s, '\n');
> +	seq_putc(s, '\n');
> +
> +	return seq_has_overflowed(s);
>  }
>  
>  static const struct seq_operations exp_seq_ops = {
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
> index 11d85b3..3e016ff 100644
> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -998,11 +998,13 @@ static int seq_show(struct seq_file *s, void *v)
>  {
>  	const struct nfulnl_instance *inst = v;
>  
> -	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
> -			  inst->group_num,
> -			  inst->peer_portid, inst->qlen,
> -			  inst->copy_mode, inst->copy_range,
> -			  inst->flushtimeout, atomic_read(&inst->use));
> +	seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
> +		   inst->group_num,
> +		   inst->peer_portid, inst->qlen,
> +		   inst->copy_mode, inst->copy_range,
> +		   inst->flushtimeout, atomic_read(&inst->use));
> +
> +	return seq_has_overflowed(s);
>  }
>  
>  static const struct seq_operations nful_seq_ops = {
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
