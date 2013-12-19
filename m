From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH net-next] vxlan: make get_rx_port static
Date: Thu, 19 Dec 2013 12:00:46 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1312191158170.30247@intel.com>
References: <20131213163722.498f6e56@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59646 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888Ab3LSTm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 14:42:58 -0500
In-Reply-To: <20131213163722.498f6e56@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 13 Dec 2013, Stephen Hemminger wrote:

> Make local function static, only used in vxlan itself right now.
> Maybe someone had ideas about offload, but they can expose it when
> they send their offload upstream.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/drivers/net/vxlan.c	2013-12-12 11:48:17.057855220 -0800
> +++ b/drivers/net/vxlan.c	2013-12-12 11:56:55.949774139 -0800
> @@ -2039,7 +2039,7 @@ static struct device_type vxlan_type = {
>   * supply the listening VXLAN udp ports. Callers are expected
>   * to implement the ndo_add_vxlan_port.
>   */
> -void vxlan_get_rx_port(struct net_device *dev)
> +static void vxlan_get_rx_port(struct net_device *dev)
>  {
>  	struct vxlan_sock *vs;
>  	struct net *net = dev_net(dev);
> --- a/include/net/vxlan.h	2013-12-12 11:48:17.057855220 -0800
> +++ b/include/net/vxlan.h	2013-12-12 11:56:55.949774139 -0800
> @@ -41,11 +41,4 @@ __be16 vxlan_src_port(__u16 port_min, __
>  /* IPv6 header + UDP + VXLAN + Ethernet header */
>  #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
>  
> -#if IS_ENABLED(CONFIG_VXLAN)
> -void vxlan_get_rx_port(struct net_device *netdev);
> -#else
> -static inline void vxlan_get_rx_port(struct net_device *netdev)
> -{
> -}
> -#endif
>  #endif
> --

Please do not apply this patch. Jeff Kirsher is about to send a patch that 
takes advantage of vxlan_get_rx_port in i40e.

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
