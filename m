From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH 2/4] uapi glibc compat: fix build if libc defines IFF_ECHO
Date: Mon, 13 Mar 2017 13:28:55 +0200
Message-ID: <20170313112855.GA8672@lakka.kapsi.fi>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-3-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:37796 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbdCML27 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 07:28:59 -0400
Content-Disposition: inline
In-Reply-To: <20170312220039.16885-3-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 11:00:37PM +0100, Hauke Mehrtens wrote:
> musl 1.1.15 defines IFF_ECHO and the other net_device_flags options.
> When a user application includes linux/if.h and net/if.h the compile
> will fail.
> 
> Activate __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO only when
> it is needed. This should also make this work in case glibc will add
> these defines.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>

> ---
>  include/uapi/linux/libc-compat.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index 7c1fead03c50..49a8cc3138ae 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -64,9 +64,11 @@
>  /* Everything up to IFF_DYNAMIC, matches net/if.h until glibc 2.23 */
>  #define __UAPI_DEF_IF_NET_DEVICE_FLAGS 0
>  /* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO */
> +#ifndef IFF_ECHO
>  #ifndef __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO
>  #define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
>  #endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO */
> +#endif /* IFF_ECHO */
>  
>  #else /* _NET_IF_H */
>  
> -- 
> 2.11.0
> 
