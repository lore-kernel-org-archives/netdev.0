From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] cxgb4: Remove redundant memset before memcpy
Date: Fri, 13 Jan 2017 16:57:14 +0100
Message-ID: <20170113155714.GE1201@distanz.ch>
References: <1484301169-11724-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Shyam Saini <mayhs11saini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:33916 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752023AbdAMP5S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 10:57:18 -0500
Content-Disposition: inline
In-Reply-To: <1484301169-11724-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-13 at 10:52:49 +0100, Shyam Saini <mayhs11saini@gmail.com> wrote:
> The region set by the call to memset, immediately overwritten by the
> subsequent call to memcpy and thus makes the  memset redundant
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/sched.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
> index cbd68a8..5725693 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
> @@ -398,7 +398,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
>  		struct ch_sched_params tp;
>  
>  		memset(&info, 0, sizeof(info));

This memset is also redundant because info is memcpy()'ed to before
being used in the loop (and it isn't used outside of the loop).

> -		memset(&tp, 0, sizeof(tp));
>  
>  		memcpy(&tp, p, sizeof(tp));
>  		/* Don't try to match class parameter */
> @@ -409,7 +408,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
>  			if (e->state == SCHED_STATE_UNUSED)
>  				continue;
>  
> -			memset(&info, 0, sizeof(info));
>  			memcpy(&info, &e->info, sizeof(info));
>  			/* Don't try to match class parameter */
>  			info.u.params.class = SCHED_CLS_NONE;
> @@ -458,7 +456,6 @@ static struct sched_class *t4_sched_class_alloc(struct port_info *pi,
>  		if (!e)
>  			goto out;
>  
> -		memset(&np, 0, sizeof(np));
>  		memcpy(&np, p, sizeof(np));
>  		np.u.params.class = e->idx;
>  
> -- 
> 2.7.4
> 
