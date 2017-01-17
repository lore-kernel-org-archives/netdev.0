From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Tue, 17 Jan 2017 20:27:33 +0200
Message-ID: <20170117202515-mutt-send-email-mst@kernel.org>
References: <20170117181351.98291-1-rolf.neugebauer@docker.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com,
        rppt@linux.vnet.ibm.com
To: Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37938 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbdAQShZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 13:37:25 -0500
Content-Disposition: inline
In-Reply-To: <20170117181351.98291-1-rolf.neugebauer@docker.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 06:13:51PM +0000, Rolf Neugebauer wrote:
> This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a
> subtle change in how the virtio_net flags are derived from the SKBs
> ip_summed field.
> 
> With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
> when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
> ip_summed == CHECKSUM_NONE, which should be the same.
> 
> Further, the virtio spec 1.0 / CS04 explicitly says that
> VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.
> 
> Signed-off-by: Rolf Neugebauer <rolf.neugebauer@docker.com>

Fixes: fd2a0437dc33 ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
Fixes: e858fae2b0b8 (" virtio_net: use common code for virtio_net_hdr and skb GSO conversion")
Acked-by: Michael S. Tsirkin <mst@redhat.com>

Should be backported into stable as well.



> ---
>  include/linux/virtio_net.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 66204007d7ac..56436472ccc7 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -91,8 +91,6 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>  				skb_checksum_start_offset(skb));
>  		hdr->csum_offset = __cpu_to_virtio16(little_endian,
>  				skb->csum_offset);
> -	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
> -		hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
>  	} /* else everything is zero */
>  
>  	return 0;
> -- 
> 2.11.0
