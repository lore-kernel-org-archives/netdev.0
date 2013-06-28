From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH v3] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Fri, 28 Jun 2013 16:18:37 -0700
Message-ID: <51CE19CD.90706@infradead.org>
References: <1372460860-19052-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	bhutchings@solarflare.com, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:34156 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab3F1XTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 19:19:08 -0400
In-Reply-To: <1372460860-19052-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/13 16:07, Pravin B Shelar wrote:
> Openvswitch uses function from NET_IPGRE_DEMUX module.
> Add Kconfig dependency to fix following compilation errors:
> http://marc.info/?l=linux-netdev&m=137244035226634
> 
> CC: Jesse Gross <jesse@nicira.com>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Pravin Shelar <pshelar@nicira.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
> v2-v3:
>  - Added openvswitch gre config option.
>  - add INET dependency.
> v1-v2:
>  - use select to resolve dependency.
> ---
>  net/openvswitch/Kconfig     |   16 ++++++++++++++--
>  net/openvswitch/vport-gre.c |    5 +++--
>  net/openvswitch/vport.c     |    2 +-
>  3 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
> index 9fbc04a..27ee56b 100644
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@ -19,8 +19,6 @@ config OPENVSWITCH
>  	  which is able to accept configuration from a variety of sources and
>  	  translate it into packet processing rules.
>  
> -	  Open vSwitch GRE support depends on CONFIG_NET_IPGRE_DEMUX.
> -
>  	  See http://openvswitch.org for more information and userspace
>  	  utilities.
>  
> @@ -28,3 +26,17 @@ config OPENVSWITCH
>  	  called openvswitch.
>  
>  	  If unsure, say N.
> +
> +config OPENVSWITCH_GRE
> +	bool "Open vSwitch GRE tunneling support"
> +	depends on INET
> +	depends on OPENVSWITCH
> +	depends on NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)
> +	default y
> +	---help---
> +	  If you say Y here, then the Open vSwitch will be able create GRE
> +	  vport.
> +
> +	  Say N to exclude this support and reduce the binary size.
> +
> +	  If unsure, say Y.
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index 943e5c4..493e977 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -16,7 +16,7 @@
>   * 02110-1301, USA
>   */
>  
> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
> +#ifdef CONFIG_OPENVSWITCH_GRE
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/if.h>
> @@ -271,4 +271,5 @@ const struct vport_ops ovs_gre_vport_ops = {
>  	.get_name	= gre_get_name,
>  	.send		= gre_tnl_send,
>  };
> -#endif
> +
> +#endif /* OPENVSWITCH_GRE */
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index ba81294..d4c7fa0 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -39,7 +39,7 @@ static const struct vport_ops *vport_ops_list[] = {
>  	&ovs_netdev_vport_ops,
>  	&ovs_internal_vport_ops,
>  
> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
> +#ifdef CONFIG_OPENVSWITCH_GRE
>  	&ovs_gre_vport_ops,
>  #endif
>  };
> 


-- 
~Randy
