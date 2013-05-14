From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv6: Add IPv6 support to the ping socket.
Date: Tue, 14 May 2013 08:16:21 -0700
Message-ID: <1368544581.4519.12.camel@edumazet-glaptop>
References: <20130514145804.3780F180460@drone2.tok.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, segoon@openwall.com,
	yoshfuji@linux-ipv6.org, edumazet@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51286 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab3ENPQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 11:16:25 -0400
Received: by mail-pb0-f48.google.com with SMTP id md4so513919pbc.21
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 08:16:24 -0700 (PDT)
In-Reply-To: <20130514145804.3780F180460@drone2.tok.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 23:58 +0900, Lorenzo Colitti wrote:
> This adds the ability to send ICMPv6 echo requests without a
> raw socket. The equivalent ability for ICMPv4 was added in
> 2011.
> 
> Instead of having separate code paths for IPv4 and IPv6, make
> most of the code in net/ipv4/ping.c dual-stack and only add a
> few IPv6-specific bits (like the protocol definition) to a new
> net/ipv6/ping.c. Hopefully this will reduce divergence and/or
> duplication of bugs in the future.
> 

Interesting, but :

> +#ifdef CONFIG_IPV6
> +#include <linux/in6.h>
> +#include <linux/icmpv6.h>
> +#include <net/addrconf.h>
> +#include <net/ipv6.h>
> +#include <net/transp_v6.h>
> +#endif
>  

This cannot possibly work with
CONFIG_IPV6=m

Please always compile/test your IPv6 patches with following possible
configurations.

1) CONFIG_IPV6=m
2) CONFIG_IPV6=y
3) # CONFIG_IPV6 is not set

Thanks !
