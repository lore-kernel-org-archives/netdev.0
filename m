From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 13/13] ipv6: Pull IPv6 GSO registration out of the
 module
Date: Fri, 16 Nov 2012 22:04:13 +0000
Message-ID: <1353103453.2743.44.camel@bwh-desktop.uk.solarflarecom.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
	 <1352856254-29667-14-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<davem@davemloft.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9600 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419Ab2KPWER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 17:04:17 -0500
In-Reply-To: <1352856254-29667-14-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 20:24 -0500, Vlad Yasevich wrote:
> Sing GSO support is now separate, pull it out of the module

Sing?  Can we dance, too?

> and make it its own init call.
> Remove the cleanup functions as they are no longer called.
[...]
> --- a/include/net/protocol.h
> +++ b/include/net/protocol.h
> @@ -25,6 +25,7 @@
>  #define _PROTOCOL_H
>  
>  #include <linux/in6.h>
> +#include <linux/skbuff.h>
>  #if IS_ENABLED(CONFIG_IPV6)
>  #include <linux/ipv6.h>
>  #endif
> @@ -59,8 +60,6 @@ struct inet6_protocol {
>  
>  #define INET6_PROTO_NOPOLICY	0x1
>  #define INET6_PROTO_FINAL	0x2
> -/* This should be set for any extension header which is compatible with GSO. */
> -#define INET6_PROTO_GSO_EXTHDR	0x4
>  #endif
>  
>  struct net_offload {
> @@ -72,6 +71,8 @@ struct net_offload {
>  	int			(*gro_complete)(struct sk_buff *skb);
>  	unsigned int		flags;	/* Flags used by IPv6 for now */
>  };
> +/* This should be set for any extension header which is compatible with GSO. */
> +#define INET6_PROTO_GSO_EXTHDR	0x1
[...]

Should be renamed to INET6_OFFLOAD_GSO_EXTHDR, matching the new
structure name.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
