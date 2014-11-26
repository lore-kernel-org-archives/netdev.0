From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v4 21/42] virtio_net: get rid of
	virtio_net_hdr/skb_vnet_hdr
Date: Wed, 26 Nov 2014 13:50:53 +0100
Message-ID: <20141126135053.1bf4f97c.cornelia.huck@de.ibm.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
	<1416933600-21398-22-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@au1.ibm.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1416933600-21398-22-git-send-email-mst@redhat.com>
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

On Tue, 25 Nov 2014 18:42:53 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> virtio 1.0 doesn't use virtio_net_hdr anymore, and in fact, it's not
> really useful since virtio_net_hdr_mrg_rxbuf includes that as the first
> field anyway.
> 
> Let's drop it, precalculate header len and store within vi instead.
> 
> This way we can also remove struct skb_vnet_hdr.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 90 ++++++++++++++++++++++--------------------------
>  1 file changed, 41 insertions(+), 49 deletions(-)
> 

> @@ -260,13 +256,11 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
> 
>  	hdr = skb_vnet_hdr(skb);
> 
> -	if (vi->mergeable_rx_bufs) {
> -		hdr_len = sizeof hdr->mhdr;
> -		hdr_padded_len = sizeof hdr->mhdr;
> -	} else {
> -		hdr_len = sizeof hdr->hdr;
> +	hdr_len = vi->hdr_len;
> +	if (vi->mergeable_rx_bufs)
> +		hdr_padded_len = sizeof *hdr;

sizeof without () looks weird to me.

> +	else
>  		hdr_padded_len = sizeof(struct padded_vnet_hdr);
> -	}
> 
>  	memcpy(hdr, p, hdr_len);
> 

Otherwise:

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
