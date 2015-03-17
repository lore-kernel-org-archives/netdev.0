From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [RFC PATCH] xen-netback: making the bandwidth limiter runtime
 settable
Date: Tue, 17 Mar 2015 11:26:44 +0000
Message-ID: <1426591604.18247.192.camel@citrix.com>
References: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16220 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866AbbCQL0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 07:26:47 -0400
In-Reply-To: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 13:51 +0100, Imre Palik wrote:
[...]
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 3aa8648..34d8038 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -463,6 +463,7 @@ int xenvif_init_queue(struct xenvif_queue *queue)
>  	queue->credit_bytes = queue->remaining_credit = ~0UL;
>  	queue->credit_usec  = 0UL;
>  	init_timer(&queue->credit_timeout);
> +	queue->credit_timeout.function = xenvif_tx_credit_callback;
>  	queue->credit_window_start = get_jiffies_64();
>  
>  	queue->rx_queue_max = XENVIF_RX_QUEUE_BYTES;
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index cab9f52..bcc1880 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
[...]
> @@ -1170,7 +1170,7 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
>  		queue->credit_timeout.data     =
>  			(unsigned long)queue;
>  		queue->credit_timeout.function =
> -			tx_credit_callback;
> +			xenvif_tx_credit_callback;

Are this init and the one in xenvif_init_queue really both needed?

Ian.
