From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] 2.6: allow CONFIG_NETFILTER=n and CONFIG_XFRM=y
Date: Tue, 27 Apr 2004 23:34:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408ED1E9.6060502@trash.net>
References: <20040427153509.GD6836@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040427153509.GD6836@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> Hi,
> 
> the following patch should fix a compile error when setting
> CONFIG_NETFILTER=n and CONFIG_XFRM=y.

This error comes from one of my netfilter+ipsec patches, which are not
in mainline yet. I'll add your fix, thanks.

Regards
Patrick

> 
> Cheers,
> Olaf
> 
> 
> ------------------------------------------------------------------------
> 
> This patch makes sure the kernel can be compiled with CONFIG_XFRM=y and
> CONFIG_NETFILTER off.
> 
> --- linux-2.6.5/include/linux/netfilter_ipv4.h.dbg	2004-04-27 13:00:55.000000000 +0200
> +++ linux-2.6.5/include/linux/netfilter_ipv4.h	2004-04-27 13:15:24.000000000 +0200
> @@ -86,7 +86,7 @@
>  extern int skb_ip_make_writable(struct sk_buff **pskb,
>  				unsigned int writable_len);
>  
> -#ifdef CONFIG_XFRM
> +#if defined(CONFIG_XFRM) && defined(CONFIG_NETFILTER)
>  #include <net/route.h>
>  #include <net/xfrm.h>
>  
