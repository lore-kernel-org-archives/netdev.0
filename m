From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Thu, 18 Apr 2013 17:34:08 +0300
Message-ID: <20130418143407.GA28374@zed.ravello.local>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
 <1366175423-27310-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:40745 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965654Ab3DROeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:34:15 -0400
Received: by mail-lb0-f197.google.com with SMTP id z13so4153888lbh.4
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:34:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1366175423-27310-4-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 01:10:20PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> This patch adds IPv6 support to vxlan device, as the new version
> RFC already mentioned it:
> 
>    http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03
> 
> Cc: David Stevens <dlstevens@us.ibm.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  drivers/net/vxlan.c          |  639 +++++++++++++++++++++++++++++++++---------
>  include/uapi/linux/if_link.h |    2 +
>  2 files changed, 505 insertions(+), 136 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index f8ac900..43ed40f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c

[ snip ]

> +#if IS_ENABLED(CONFIG_IPV6)
> +	else {
> +		loopback.va_sin6 = in6addr_loopback;

When building vxlan as module I get:

MODPOST 45 modules
VOFFSET arch/x86/boot/voffset.h
CC      arch/x86/boot/version.o
AS      arch/x86/boot/compressed/head_64.o
ERROR: "in6addr_loopback" [drivers/net/vxlan.ko] undefined!

Seems, that either in6addr_loopback should be exported, or
IN6ADDR_LOOPBACK_INIT should be used as initializer for
loopback.va_sin6.

> +		loopback.va_sa =  AF_INET6;
> +	}
> +#endif
> +
>  	if (dst_vxlan->flags & VXLAN_F_LEARN)
> -		vxlan_snoop(skb->dev, htonl(INADDR_LOOPBACK),
> -			    eth_hdr(skb)->h_source);
> +		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source);
>  
>  	u64_stats_update_begin(&tx_stats->syncp);
>  	tx_stats->tx_packets++;

--
Sincerely yours,
Mike.
