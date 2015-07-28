From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] af_mpls: fix undefined reference to
 ip6_route_output
Date: Mon, 27 Jul 2015 21:20:41 -0700 (PDT)
Message-ID: <20150727.212041.2269026145203619118.davem@davemloft.net>
References: <1438044077-1910-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbbG1EUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 00:20:44 -0400
In-Reply-To: <1438044077-1910-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 27 Jul 2015 17:41:17 -0700

> @@ -33,4 +33,11 @@ config MPLS_IPTUNNEL
>  	---help---
>  	 mpls ip tunnel support.
>  
> +config MPLS_NEXTHOP_DEVLOOKUP
> +	bool "MPLS: nexthop oif dev lookup"
> +	depends on MPLS_ROUTING && INET && (IPV6 || IPV6=n)
> +	---help---
> +	 This enables mpls route nexthop dev lookup when oif is not
> +	 specified by user


This still allows the illegal combination, how did you test this?

CONFIG_IPV6=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
CONFIG_MPLS_IPTUNNEL=y
CONFIG_MPLS_NEXTHOP_DEVLOOKUP=y

net/built-in.o: In function `find_outdev':
af_mpls.c:(.text+0x17df41): undefined reference to `ip6_route_output'

The situation that must be prevented is MPLS_ROUTING=y + IPV6=m,
but that's exactly what is being allowed even after your patch.

Again, how did you test this?  Did you try the case that causes
problems as indicated in the failure reports?
