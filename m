From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Mon, 18 Sep 2006 20:57:46 +0200
Message-ID: <20060918185746.GD18349@postel.suug.ch>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:28325 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932209AbWIRS5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 14:57:25 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-09-19 00:08
>     [NET]: Move netlink interface bits to linux/if_link.h.
>     
>     Moving netlink interface bits to linux/if.h is rather troublesome for
>     applications including both linux/if.h (which was changed to be included
>     from linux/rtnetlink.h automatically) and net/if.h.

Agreed.

>     [NET]: Include new rtnetlink headers for userspace backward compatibility.
>     
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 3a18add..8ec375c 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -2,7 +2,12 @@ #ifndef __LINUX_RTNETLINK_H
>  #define __LINUX_RTNETLINK_H
>  
>  #include <linux/netlink.h>
> +#ifndef __KERNEL__
> +/* Backward compatibility */
>  #include <linux/if_link.h>
> +#include <linux/if_addr.h>
> +#include <linux/neighbour.h>
> +#endif
>  
>  /****
>   *		Routing/neighbour discovery messages.

Still acceptable but this gets ugly at some point. Applications using
the interface should start making copies of the header version they
use.

> commit 55a08a9078b243a06223222735580df9e11a5fa6
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Sun Sep 17 13:55:02 2006 +0900
> 
>     [NET]: Put {IFLA,IFA,NDA,NDTA}_{RTA,PAYLOAD}() macro back.
>     
>     These macros are still used by userspace applications.

Same here, it doesn't make sense to export macros only of functional
value and used by userspace only. The same issue will pop up once
all users have been converted to use the new netlink interface.
Keeping the old interface around just so userspace doesn't have to
make copies doesn't make sense. I think it's better to start fixing
userspace than to try and keep headers source compatible.
