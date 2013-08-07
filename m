From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH v4 2/3] net: igmp: Don't flush routing cache when force_igmp_version is modified
Date: Wed, 7 Aug 2013 09:43:08 -0400
Message-ID: <20130807134308.GK8043@kvack.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <1375812195-6575-3-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net, hannes@stressinduktion.org
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:36107 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933144Ab3HGNnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 09:43:09 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-3-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:14PM +0100, William Manley wrote:
> The procfs knob /proc/sys/net/ipv4/conf/*/force_igmp_version allows the
> IGMP protocol version to use to be explicitly set.  As a side effect this
> caused the routing cache to be flushed as it was declared as a
> DEVINET_SYSCTL_FLUSHING_ENTRY.  Flushing is unnecessary and this patch
> makes it so flushing does not occur.
> 
> Requested by Hannes Frederic Sowa as he was reviewing other patches
> adding procfs entries.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: William Manley <william.manley@youview.com>

Acked-by: Benjamin LaHaise <bcrl@kvack.org>

Looks good.

> ---
>  include/linux/inetdevice.h |    2 +-
>  net/ipv4/devinet.c         |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index ea1e3b8..d4c56fc 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -27,9 +27,9 @@ enum
>  	IPV4_DEVCONF_TAG,
>  	IPV4_DEVCONF_ARPFILTER,
>  	IPV4_DEVCONF_MEDIUM_ID,
> +	IPV4_DEVCONF_FORCE_IGMP_VERSION,
>  	IPV4_DEVCONF_NOXFRM,
>  	IPV4_DEVCONF_NOPOLICY,
> -	IPV4_DEVCONF_FORCE_IGMP_VERSION,
>  	IPV4_DEVCONF_ARP_ANNOUNCE,
>  	IPV4_DEVCONF_ARP_IGNORE,
>  	IPV4_DEVCONF_PROMOTE_SECONDARIES,
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index dfc39d4..a9561c4 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2094,11 +2094,11 @@ static struct devinet_sysctl_table {
>  		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
>  		DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
>  		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP_PVLAN, "proxy_arp_pvlan"),
> +		DEVINET_SYSCTL_RW_ENTRY(FORCE_IGMP_VERSION,
> +					"force_igmp_version"),
>  
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
> -		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
> -					      "force_igmp_version"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
>  					      "promote_secondaries"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
> -- 
> 1.7.10.4

-- 
"Thought is the essence of where you are now."
