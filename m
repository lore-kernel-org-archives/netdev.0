From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 3/5] xen-netback: Unconditionally set
 NETIF_F_RXCSUM
Date: Mon, 14 Oct 2013 11:56:16 +0100
Message-ID: <1381748176.24708.103.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-4-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56872 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755867Ab3JNK4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 06:56:19 -0400
In-Reply-To: <1381503982-1418-4-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> There is no mechanism to insist that a guest always generates a packet
> with good checksum (at least for IPv4)

Isn't this what feature-no-csum-offload is?

>  so we must handle checksum
> offloading from the guest and hence should set NETIF_F_RXCSUM.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 8e92783..cb0d8ea 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -321,7 +321,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	dev->hw_features = NETIF_F_SG |
>  		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  		NETIF_F_TSO;
> -	dev->features = dev->hw_features;
> +	dev->features = dev->hw_features | NETIF_F_RXCSUM;
>  	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
>  
>  	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
