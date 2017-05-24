From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v9 5/5] virtio_net: check return value of
 skb_to_sgvec always
Date: Wed, 24 May 2017 12:41:15 +0300
Message-ID: <911d6dda-85de-ba8d-0c84-6a37e91523de@cogentembedded.com>
References: <20170523160550.5203-1-Jason@zx2c4.com>
 <20170523160550.5203-6-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523160550.5203-6-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 5/23/2017 7:05 PM, Jason A. Donenfeld wrote:

> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9320d96a1632..13fbe4b349c2 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1150,7 +1150,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  	struct virtio_net_hdr_mrg_rxbuf *hdr;
>  	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
>  	struct virtnet_info *vi = sq->vq->vdev->priv;
> -	unsigned num_sg;
> +	int num_sg;
>  	unsigned hdr_len = vi->hdr_len;
>  	bool can_push;
>
> @@ -1177,11 +1177,16 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  	if (can_push) {
>  		__skb_push(skb, hdr_len);
>  		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
> +                if (unlikely(num_sg < 0))

    Please indent with tabs, like above and below.

> +			return num_sg;
>  		/* Pull header back to avoid skew in tx bytes calculations. */
>  		__skb_pull(skb, hdr_len);
[...]

MBR, Sergei
