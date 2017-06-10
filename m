From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: use read_lock_bh in sctp_eps_seq_show
Date: Sat, 10 Jun 2017 13:02:05 -0300
Message-ID: <20170610160205.GC5799@localhost.localdomain>
References: <f845585a99f0cb76659f4d5dae4f7d6fd5552224.1497078812.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751912AbdFJQCI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 12:02:08 -0400
Content-Disposition: inline
In-Reply-To: <f845585a99f0cb76659f4d5dae4f7d6fd5552224.1497078812.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 03:13:32PM +0800, Xin Long wrote:
> This patch is to use read_lock_bh instead of local_bh_disable
> and read_lock in sctp_eps_seq_show.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/proc.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 5a27d0f..8e34db5 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -218,8 +218,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>  		return -ENOMEM;
>  
>  	head = &sctp_ep_hashtable[hash];
> -	local_bh_disable();
> -	read_lock(&head->lock);
> +	read_lock_bh(&head->lock);
>  	sctp_for_each_hentry(epb, &head->chain) {
>  		ep = sctp_ep(epb);
>  		sk = epb->sk;
> @@ -234,8 +233,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>  		sctp_seq_dump_local_addrs(seq, epb);
>  		seq_printf(seq, "\n");
>  	}
> -	read_unlock(&head->lock);
> -	local_bh_enable();
> +	read_unlock_bh(&head->lock);
>  
>  	return 0;
>  }
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
