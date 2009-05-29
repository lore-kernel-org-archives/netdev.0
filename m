From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 9/10]: irda: Use SKB queue and list helpers instead of
	doing it by-hand.
Date: Fri, 29 May 2009 12:36:20 +0200
Message-ID: <1243593380.8750.0.camel@sortiz-mobl>
References: <20090529.014025.223389403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090529.014025.223389403.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-05-29 at 01:40 -0700, David Miller wrote:
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Acked-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

Cheers,
Samuel.

> ---
>  net/irda/irlap_frame.c |   18 ++----------------
>  1 files changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
> index 2562ebc..7af2e74 100644
> --- a/net/irda/irlap_frame.c
> +++ b/net/irda/irlap_frame.c
> @@ -982,17 +982,12 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
>  {
>  	struct sk_buff *tx_skb;
>  	struct sk_buff *skb;
> -	int count;
>  
>  	IRDA_ASSERT(self != NULL, return;);
>  	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
>  
> -	/* Initialize variables */
> -	count = skb_queue_len(&self->wx_list);
> -
>  	/*  Resend unacknowledged frame(s) */
> -	skb = skb_peek(&self->wx_list);
> -	while (skb != NULL) {
> +	skb_queue_walk(&self->wx_list, skb) {
>  		irlap_wait_min_turn_around(self, &self->qos_tx);
>  
>  		/* We copy the skb to be retransmitted since we will have to
> @@ -1011,21 +1006,12 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
>  		/*
>  		 *  Set poll bit on the last frame retransmitted
>  		 */
> -		if (count-- == 1)
> +		if (skb_queue_is_last(&self->wx_list, skb))
>  			tx_skb->data[1] |= PF_BIT; /* Set p/f bit */
>  		else
>  			tx_skb->data[1] &= ~PF_BIT; /* Clear p/f bit */
>  
>  		irlap_send_i_frame(self, tx_skb, command);
> -
> -		/*
> -		 *  If our skb is the last buffer in the list, then
> -		 *  we are finished, if not, move to the next sk-buffer
> -		 */
> -		if (skb == skb_peek_tail(&self->wx_list))
> -			skb = NULL;
> -		else
> -			skb = skb->next;
>  	}
>  #if 0 /* Not yet */
>  	/*

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
