From: Jeff Garzik <jeff@garzik.org>
Subject: Re: cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq
Date: Tue, 21 Oct 2008 02:10:17 -0400
Message-ID: <48FD7249.5040001@garzik.org>
References: <ada63nqsyxp.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, davem@davemloft.net
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46170 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbYJUGKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:10:22 -0400
In-Reply-To: <ada63nqsyxp.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> Commit 147e70e6 ("cxgb3: Use SKB list interfaces instead of home-grown
> implementation.") causes a crash in t3_l2t_send_slow() when an iWARP
> connection request is received.  This is because the new l2t_entry.arpq
> skb queue is never initialized, and therefore trying to add an skb to
> it causes a NULL dereference.  With the old code there was no need to
> initialize the queues because the l2t_entry structures were zeroed,
> and the code used NULL to mean empty.
> 
> Fix this by adding __skb_queue_head_init() when all the l2t_entry
> structures get allocated.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
> This should probably go to -stable as well, since it looks like the
> commit that broke things went into 2.6.27-rc6.
> 
>  drivers/net/cxgb3/l2t.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
> index 4407ac9..ff1611f 100644
> --- a/drivers/net/cxgb3/l2t.c
> +++ b/drivers/net/cxgb3/l2t.c
> @@ -431,6 +431,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
>  	for (i = 0; i < l2t_capacity; ++i) {
>  		d->l2tab[i].idx = i;
>  		d->l2tab[i].state = L2T_STATE_UNUSED;
> +		__skb_queue_head_init(&d->l2tab[i].arpq);
>  		spin_lock_init(&d->l2tab[i].lock);
>  		atomic_set(&d->l2tab[i].refcnt, 0);

applied


