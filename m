From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: do not rate limit counter increments
Date: Wed, 28 Mar 2012 10:30:46 +0200
Message-ID: <20120328083046.GA5873@redhat.com>
References: <20120327172809.C52572900384@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

On Tue, Mar 27, 2012 at 10:28:09AM -0700, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> While it is desirable to rate limit certain messages, it is not
> desirable to rate limit the incrementing of counters associated
> with those messages.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

Dave, can you apply pls? Thanks!

> ---
> 
> Compiled, and run briefly in a 1 vCPU guest under a netperf workload.
> 
> 
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
