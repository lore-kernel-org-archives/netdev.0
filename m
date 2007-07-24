From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] Netfilter Kconfig:  Expose IPv4/6 connection tracking options by selecting NF_CONNTRACK
Date: Tue, 24 Jul 2007 07:52:08 +0200
Message-ID: <20070724055208.GB12946@uranus.ravnborg.org>
References: <200707240836.33494.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Al Boldi <a1426z@gawab.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200707240836.33494.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 08:36:33AM +0300, Al Boldi wrote:
> 
> Replaces NF_CONNTRACK_ENABLED with NF_CONNTRACK and selects it for 
> NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6
> 
> This exposes IPv4/6 connection tracking options for easier Kconfig setup.
> 
> Signed-off-by: Al Boldi <a1426z@gawab.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> --- a/net/netfilter/Kconfig	2007-07-09 06:38:52.000000000 +0300
> +++ b/net/netfilter/Kconfig	2007-07-24 08:28:06.000000000 +0300
> @@ -25,8 +25,7 @@ config NETFILTER_NETLINK_LOG
>  	  and is also scheduled to replace the old syslog-based ipt_LOG
>  	  and ip6t_LOG modules.
>  
> -# Rename this to NF_CONNTRACK in a 2.6.25
> -config NF_CONNTRACK_ENABLED
> +config NF_CONNTRACK
>  	tristate "Netfilter connection tracking support"
>  	help
>  	  Connection tracking keeps a record of what packets have passed
> @@ -40,10 +39,6 @@ config NF_CONNTRACK_ENABLED
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> -config NF_CONNTRACK
> -	tristate
> -	default NF_CONNTRACK_ENABLED
> -
>  config NF_CT_ACCT
>  	bool "Connection tracking flow accounting"
>  	depends on NF_CONNTRACK
> --- a/net/ipv4/netfilter/Kconfig	2007-07-09 06:38:50.000000000 +0300
> +++ b/net/ipv4/netfilter/Kconfig	2007-07-24 08:27:39.000000000 +0300
> @@ -7,7 +7,7 @@ menu "IP: Netfilter Configuration"
>  
>  config NF_CONNTRACK_IPV4
>  	tristate "IPv4 connection tracking support (required for NAT)"
> -	depends on NF_CONNTRACK
> +	select NF_CONNTRACK
>  	---help---
>  	  Connection tracking keeps a record of what packets have passed
>  	  through your machine, in order to figure out how they are related
> --- a/net/ipv6/netfilter/Kconfig	2007-07-09 06:38:51.000000000 +0300
> +++ b/net/ipv6/netfilter/Kconfig	2007-07-24 08:27:54.000000000 +0300
> @@ -7,7 +7,8 @@ menu "IPv6: Netfilter Configuration (EXP
>  
>  config NF_CONNTRACK_IPV6
>  	tristate "IPv6 connection tracking support (EXPERIMENTAL)"
> -	depends on INET && IPV6 && EXPERIMENTAL && NF_CONNTRACK
> +	depends on INET && IPV6 && EXPERIMENTAL
> +	select NF_CONNTRACK
>  	---help---
>  	  Connection tracking keeps a record of what packets have passed
>  	  through your machine, in order to figure out how they are related
> 
This change looks wrong.
Due to the reverse nature of "select" kconfig cannot fulfill the dependencies
of selected symbols. So as a rule of thumb select should only select
symbols with no menu and no dependencies to avoid some of the
problems that have popped up during the last months.

	Sam
