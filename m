From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] include/linux/netfilter_bridge.h: header cleanup
Date: Sun, 30 Jul 2006 11:03:12 +0100
Message-ID: <1154253792.3025.33.camel@pmac.infradead.org>
References: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org, dot@dotat.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:48027 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1751382AbWG3KDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 06:03:55 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-07-29 at 11:45 +0400, Alexey Dobriyan wrote:
> Header doesn't use anything from atomic.h.
> It fixes headers_check warning:
> 
> include/linux/netfilter_bridge.h requires asm/atomic.h, which does not exist
> 
> Compile tested on
> alpha     arm   i386-up  sparc    sparc64-up  x86_64
> alpha-up  i386           sparc64  sparc-up    x86_64-up
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/linux/netfilter_bridge.h |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- a/include/linux/netfilter_bridge.h
> +++ b/include/linux/netfilter_bridge.h
> @@ -6,7 +6,6 @@ #define __LINUX_BRIDGE_NETFILTER_H
>  
>  #include <linux/netfilter.h>
>  #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
> -#include <asm/atomic.h>
>  #include <linux/if_ether.h>
>  #endif

Hm, that could have been dropped entirely by '#unifdef -U__KERNEL__'.
P'raps we could teach unifdef that '#if defined(FOO) && ...' is always
false if -UFOO.

Dropping the include in this case is _also_ the right thing to do
though, since it doesn't actually need to be there even for in-kernel
compilation.

-- 
dwmw2

