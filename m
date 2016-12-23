From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/9] virtio-net: remove the warning before XDP linearizing
Date: Fri, 23 Dec 2016 20:31:53 +0100
Message-ID: <585D7BA9.50509@iogearbox.net>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com> <1482503852-12438-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482503852-12438-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jason,

On 12/23/2016 03:37 PM, Jason Wang wrote:
> Since we use EWMA to estimate the size of rx buffer. When rx buffer
> size is underestimated, it's usual to have a packet with more than one
> buffers. Consider this is not a bug, remove the warning and correct
> the comment before XDP linearizing.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/virtio_net.c | 8 +-------
>   1 file changed, 1 insertion(+), 7 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 08327e0..1067253 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -552,14 +552,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   		struct page *xdp_page;
>   		u32 act;
>
> -		/* No known backend devices should send packets with
> -		 * more than a single buffer when XDP conditions are
> -		 * met. However it is not strictly illegal so the case
> -		 * is handled as an exception and a warning is thrown.
> -		 */
> +		/* This happens when rx buffer size is underestimated */
>   		if (unlikely(num_buf > 1)) {
> -			bpf_warn_invalid_xdp_buffer();

Could you also remove the bpf_warn_invalid_xdp_buffer(), which got added
just for this?

Thanks.

>   			/* linearize data for XDP */
>   			xdp_page = xdp_linearize_page(rq, num_buf,
>   						      page, offset, &len);
>
