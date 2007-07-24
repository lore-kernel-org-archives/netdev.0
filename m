From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Netfilter Kconfig:  Expose IPv4/6 connection tracking
 options by selecting NF_CONNTRACK
Date: Tue, 24 Jul 2007 19:35:57 +0200
Message-ID: <46A6387D.1030601@trash.net>
References: <200707240836.33494.a1426z@gawab.com> <20070724055208.GB12946@uranus.ravnborg.org> <46A62FB0.2090405@trash.net> <200707242031.58910.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Al Boldi <a1426z@gawab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62669 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbXGXRga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 13:36:30 -0400
In-Reply-To: <200707242031.58910.a1426z@gawab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Patrick McHardy wrote:
> 
>>But I vaguely recall having tried this myself and it broke somewhere,
>>maybe it was because of the NF_CONNTRACK_ENABLED option, I can't
>>recall anymore. Al, if this also works without removal of
>>NF_CONNTRACK_ENABLED, please resend without that part.
> 
> 
> It doesn't.  But how about this, if you really can't live without 
> NF_CONNTRACK_ENBLED:
> 
> ==================
> --- Kconfig.old	2007-07-09 06:38:52.000000000 +0300
> +++ Kconfig	2007-07-24 20:24:27.000000000 +0300
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
> @@ -40,9 +39,9 @@ config NF_CONNTRACK_ENABLED
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> -config NF_CONNTRACK
> +config NF_CONNTRACK_ENABLED
>  	tristate
> -	default NF_CONNTRACK_ENABLED
> +	default NF_CONNTRACK
>  
>  config NF_CT_ACCT
>  	bool "Connection tracking flow accounting"


That defeats the only purpose why we kept it. How about we change this
once we remove it, in 2.6.25?
