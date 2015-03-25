From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio: change comment in transmit
Date: Wed, 25 Mar 2015 14:29:38 +1030
Message-ID: <87y4mlhglx.fsf@rustcorp.com.au>
References: <20150324162207.6d4ecf48@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150324162207.6d4ecf48@urahara>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:
> The original comment was not really informative or funny
> as well as sexist. Replace it with a better explanation of
> why the driver does stop and what the impacts are.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Fair call.  Comment was certainly snarky, probably sexist.  I think it
expressed my feelings perfectly, however.

I note that there's still no comment saying "don't do this" in
netdevice.h; I gather returning NETDEV_TX_BUSY is still considered a Bad
Thing?

(Does it really BUG_ON?)

Thanks,
Rusty.

> --- a/drivers/net/virtio_net.c	2015-03-24 15:20:25.174671000 -0700
> +++ b/drivers/net/virtio_net.c	2015-03-24 16:17:28.478525333 -0700
> @@ -939,8 +939,12 @@ static netdev_tx_t start_xmit(struct sk_
>  	skb_orphan(skb);
>  	nf_reset(skb);
>  
> -	/* Apparently nice girls don't return TX_BUSY; stop the queue
> -	 * before it gets out of hand.  Naturally, this wastes entries. */
> +	/* It is better to stop queue if running out of space
> +	 * instead of forcing queuing layer to requeue the skb
> +	 * by returning TX_BUSY (and cause a BUG message).
> +	 * Since most packets only take 1 or 2 ring slots
> +	 * this means 16 slots are typically wasted.
> +	 */
>  	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
>  		netif_stop_subqueue(dev, qnum);
>  		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
