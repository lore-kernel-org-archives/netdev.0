From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: unbreak cusmed packet for small buffer XDP
Date: Wed, 28 Jun 2017 05:02:46 +0300
Message-ID: <20170628050057-mutt-send-email-mst@kernel.org>
References: <1498614843-8163-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1498614843-8163-1-git-send-email-jasowang@redhat.com>
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

On Wed, Jun 28, 2017 at 09:54:03AM +0800, Jason Wang wrote:
> We should allow csumed packet for small buffer, otherwise XDP_PASS
> won't work correctly.
> 
> Fixes commit bb91accf2733 ("virtio-net: XDP support for small buffers")
> Signed-off-by: Jason Wang <jasowang@redhat.com>

The issue would be VIRTIO_NET_HDR_F_DATA_VALID might be set.
What do you think?

> ---
> The patch is needed for -stable.
> ---
>  drivers/net/virtio_net.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 143d8a9..499fcc9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -413,7 +413,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  		void *orig_data;
>  		u32 act;
>  
> -		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
> +		if (unlikely(hdr->hdr.gso_type))
>  			goto err_xdp;
>  
>  		xdp.data_hard_start = buf + VIRTNET_RX_PAD + vi->hdr_len;
> -- 
> 2.7.4
