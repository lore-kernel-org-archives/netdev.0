From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next]vhost: fix condition check for # of outstanding
 dma buffers
Date: Tue, 19 Jul 2011 22:09:45 +0300
Message-ID: <20110719190945.GB8667@redhat.com>
References: <1311100678.8573.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab1GSTJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 15:09:30 -0400
Content-Disposition: inline
In-Reply-To: <1311100678.8573.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 11:37:58AM -0700, Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
>  drivers/vhost/net.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 70ac604..83cb738 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -189,8 +189,10 @@ static void handle_tx(struct vhost_net *net)
>  				break;
>  			}
>  			/* If more outstanding DMAs, queue the work */
> -			if (unlikely(vq->upend_idx - vq->done_idx >
> -				     VHOST_MAX_PEND)) {
> +			if (unlikely((vq->upend_idx - vq->done_idx >
> +					VHOST_MAX_PEND) ||
> +				     (vq->upend_idx - vq->done_idx >
> +					 VHOST_MAX_PEND - UIO_MAXIOV))) {

Could you please explain why this makes sense please?
VHOST_MAX_PEND is 128 UIO_MAXIOV is 1024 so
the result is negative?

I thought upend_idx - done_idx is exactly the number
of buffers, so once we get too many we stop until
one gets freed?


>  				tx_poll_start(net, sock);
>  				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>  				break;
> 
