From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH 1/4] uapi glibc compat: add libc compat code when not
 build for kernel
Date: Mon, 13 Mar 2017 13:28:04 +0200
Message-ID: <20170313112804.GZ8672@lakka.kapsi.fi>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-2-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:50955 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbdCML2M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 07:28:12 -0400
Content-Disposition: inline
In-Reply-To: <20170312220039.16885-2-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 11:00:36PM +0100, Hauke Mehrtens wrote:
> Instead of checking if this header file is used in the glibc, check if
> iti is not used in kernel context, this way it will also work with
> other libc implementations like musl.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Accked-by: Mikko Rapeli <mikko.rapeli@iki.fi>

> ---
>  include/uapi/linux/libc-compat.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index 44b8a6bd5fe1..7c1fead03c50 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -48,8 +48,8 @@
>  #ifndef _UAPI_LIBC_COMPAT_H
>  #define _UAPI_LIBC_COMPAT_H
>  
> -/* We have included glibc headers... */
> -#if defined(__GLIBC__)
> +/* We have included libc headers... */
> +#if !defined(__KERNEL__)
>  
>  /* Coordinate with glibc net/if.h header. */
>  #if defined(_NET_IF_H) && defined(__USE_MISC)
> @@ -168,7 +168,7 @@
>  /* If we did not see any headers from any supported C libraries,
>   * or we are being included in the kernel, then define everything
>   * that we need. */
> -#else /* !defined(__GLIBC__) */
> +#else /* defined(__KERNEL__) */
>  
>  /* Definitions for if.h */
>  #define __UAPI_DEF_IF_IFCONF 1
> @@ -208,6 +208,6 @@
>  /* Definitions for xattr.h */
>  #define __UAPI_DEF_XATTR		1
>  
> -#endif /* __GLIBC__ */
> +#endif /* __KERNEL__ */
>  
>  #endif /* _UAPI_LIBC_COMPAT_H */
> -- 
> 2.11.0
> 
