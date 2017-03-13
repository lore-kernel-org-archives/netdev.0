From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH 3/4] uapi glibc compat: Do not check for __USE_MISC
Date: Mon, 13 Mar 2017 13:29:58 +0200
Message-ID: <20170313112958.GB8672@lakka.kapsi.fi>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-4-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:44333 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751264AbdCMLaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 07:30:02 -0400
Content-Disposition: inline
In-Reply-To: <20170312220039.16885-4-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 11:00:38PM +0100, Hauke Mehrtens wrote:
> __USE_MISC is glibc specific and not available in musl libc. Only do
> this check when glibc is used. This fixes a problem with musl libc.

> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>

> ---
>  include/uapi/linux/libc-compat.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index 49a8cc3138ae..ce2fa8a4ced6 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -51,8 +51,8 @@
>  /* We have included libc headers... */
>  #if !defined(__KERNEL__)
>  
> -/* Coordinate with glibc net/if.h header. */
> -#if defined(_NET_IF_H) && defined(__USE_MISC)
> +/* Coordinate with libc net/if.h header. */
> +#if defined(_NET_IF_H) && (!defined(__GLIBC__) || defined(__USE_MISC))
>  
>  /* GLIBC headers included first so don't define anything
>   * that would already be defined. */
> -- 
> 2.11.0
> 
