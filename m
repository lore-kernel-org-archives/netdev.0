From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] if_bridge: fix conflict with glibc
Date: Wed, 10 Dec 2014 13:34:17 -0500 (EST)
Message-ID: <20141210.133417.152985082992875227.davem@davemloft.net>
References: <20141209203007.188651df@urahara>
	<20141209.234954.1634249639621060084.davem@davemloft.net>
	<20141209214122.76b15851@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.0xf0@gmail.com, f.fainelli@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbaLJSeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:34:20 -0500
In-Reply-To: <20141209214122.76b15851@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 9 Dec 2014 21:41:22 -0800

> Even though kernel and glibc headers have same effective values
> Gcc complains about redefinitions. Since this is a header expected
> to be used by userspace, use glibc header.
> 
> This supersedes change in commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7
> and fixes build of iproute2 with Glibc-2.19. This follows similar usage
> in include/uapi/linux for l2tp.h
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/include/uapi/linux/if_bridge.h	2014-12-09 20:25:21.656016605 -0800
> +++ b/include/uapi/linux/if_bridge.h	2014-12-09 21:32:01.391034756 -0800
> @@ -15,7 +15,9 @@
>  
>  #include <linux/types.h>
>  #include <linux/if_ether.h>
> -#include <linux/in6.h>
> +#ifndef __KERNEL__
> +#include <netinet/in.h>
> +#endif

No, we really want to incluse the linux/in6.h header, as that's where all
the special GLIBC CPP checks are, such as:

#if __UAPI_DEF_IN6_ADDR_ALT

Please research how we have resolved the conflict between GLIBC and the
kernel's exported headers.  We really need to use linux/in6.h for all of
this to work.

I understand that it is upsetting that iproute2 stopped building for you,
but I'd like to kindly ask that you look more deeply into this and think
more longer term, rather than having a knee jerk reaction and looking for
quick fixes.

Thanks.
