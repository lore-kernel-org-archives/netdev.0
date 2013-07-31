From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH 2/4] USB: XHCI: mark no_sg_limit
Date: Wed, 31 Jul 2013 09:40:26 -0700
Message-ID: <20130731164026.GB5714@xanatos>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
 <1375267909-30373-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25376 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894Ab3GaQk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 12:40:27 -0400
Content-Disposition: inline
In-Reply-To: <1375267909-30373-3-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 06:51:47PM +0800, Ming Lei wrote:
> This patch marks all xHCI controllers as no_sg_limit since
> xHCI supports building packet from discontinuous buffers.
> 
> Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

Acked-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>

> ---
>  drivers/usb/host/xhci.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/usb/host/xhci.c b/drivers/usb/host/xhci.c
> index 2c49f00..541b155 100644
> --- a/drivers/usb/host/xhci.c
> +++ b/drivers/usb/host/xhci.c
> @@ -4841,6 +4841,10 @@ int xhci_gen_setup(struct usb_hcd *hcd, xhci_get_quirks_t get_quirks)
>  
>  	/* Accept arbitrarily long scatter-gather lists */
>  	hcd->self.sg_tablesize = ~0;
> +
> +	/* support to build packet from discontinuous buffers */
> +	hcd->self.no_sg_limit = 1;
> +
>  	/* XHCI controllers don't stop the ep queue on short packets :| */
>  	hcd->self.no_stop_on_short = 1;
>  
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
