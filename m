From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 6/8] xen-netback: pass an L4 or L3 skb hash
 value to the frontend
Date: Mon, 26 Oct 2015 17:05:45 +0000
Message-ID: <20151026170545.GF18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-7-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38080 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbbJZRGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:06:34 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-7-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:23AM +0100, Paul Durrant wrote:
> If the frontend indicates it's capable (see netif.h for details) and an
> skb has an L4 or L3 hash value then pass the value to the frontend in
> a xen_netif_extra_info segment.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>

>  static int xenvif_rx_ring_slots_needed(struct xenvif *vif)
>  {
> -	if (vif->gso_mask)
> -		return DIV_ROUND_UP(vif->dev->gso_max_size, PAGE_SIZE) + 1;
> +	int needed;
> +
> +	if (vif->gso_mask || vif->gso_prefix_mask)

It seems like this line should become a patch for -stable?

>  		xenvif_add_frag_responses(queue, status,
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 2fa8a16..a31bcee 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -1037,6 +1037,11 @@ static int read_xenbus_vif_flags(struct backend_info *be)
>  		val = 0;
>  	vif->multicast_control = !!val;
>  
> +	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-hash",
> +			 "%d", &val) < 0)
> +		val = 0;

Again, feel free to retain my reviewed-by if this changes in next
version.

Wei.

> +	vif->hash_extra = !!val;
> +
>  	return 0;
>  }
>  
> -- 
> 2.1.4
