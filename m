From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio_net: do not rate limit counter increments
Date: Wed, 28 Mar 2012 16:33:22 +1030
Message-ID: <87r4wd9s9h.fsf@rustcorp.com.au>
References: <20120327172809.C52572900384@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120327172809.C52572900384@tardy>
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

On Tue, 27 Mar 2012 10:28:09 -0700 (PDT), raj@tardy.cup.hp.com (Rick Jones) wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> While it is desirable to rate limit certain messages, it is not
> desirable to rate limit the incrementing of counters associated
> with those messages.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 019da01..4de2760 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -625,12 +625,13 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
> -		if (net_ratelimit()) {
> -			if (likely(capacity == -ENOMEM)) {
> +		if (likely(capacity == -ENOMEM)) {
> +			if (net_ratelimit()) {
>  				dev_warn(&dev->dev,
>  					 "TX queue failure: out of memory\n");
>  			} else {
> -				dev->stats.tx_fifo_errors++;
> +			dev->stats.tx_fifo_errors++;
> +			if (net_ratelimit())
>  				dev_warn(&dev->dev,
>  					 "Unexpected TX queue failure: %d\n",
>  					 capacity);
> 

-- 
  How could I marry someone with more hair than me?  http://baldalex.org
