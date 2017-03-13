From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH 4/4] uapi/if_ether.h: prevent redefinition of struct
 ethhdr
Date: Mon, 13 Mar 2017 13:31:10 +0200
Message-ID: <20170313113110.GC8672@lakka.kapsi.fi>
References: <20170312220039.16885-1-hauke@hauke-m.de>
 <20170312220039.16885-5-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170312220039.16885-5-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 12, 2017 at 11:00:39PM +0100, Hauke Mehrtens wrote:
> From: David Heidelberger <david.heidelberger@ixit.cz>
> 
> Musl provides its own ethhdr struct definition. Add a guard to prevent
> its definition of the appropriate musl header has already been included.
> 
> Signed-off-by: John Spencer <maillist-linux@barfooze.de>
> Tested-by: David Heidelberger <david.heidelberger@ixit.cz>
> Signed-off-by: Jonas Gorski <jogo@openwrt.org>

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>

> ---
>  include/uapi/linux/if_ether.h    |  3 +++
>  include/uapi/linux/libc-compat.h | 11 +++++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 5bc9bfd816b7..fb5ab8c1e753 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -22,6 +22,7 @@
>  #define _UAPI_LINUX_IF_ETHER_H
>  
>  #include <linux/types.h>
> +#include <linux/libc-compat.h>
>  
>  /*
>   *	IEEE 802.3 Ethernet magic constants.  The frame sizes omit the preamble
> @@ -142,11 +143,13 @@
>   *	This is an Ethernet frame header.
>   */
>  
> +#if __UAPI_DEF_ETHHDR
>  struct ethhdr {
>  	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
>  	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
>  	__be16		h_proto;		/* packet type ID field	*/
>  } __attribute__((packed));
> +#endif
>  
>  
>  #endif /* _UAPI_LINUX_IF_ETHER_H */
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index ce2fa8a4ced6..c92d32f213d1 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -87,6 +87,14 @@
>  
>  #endif /* _NET_IF_H */
>  
> +/* musl defines the ethhdr struct itself in its netinet/if_ether.h.
> + * Glibc just includes the kernel header and uses a different guard. */
> +#if defined(_NETINET_IF_ETHER_H)
> +#define __UAPI_DEF_ETHHDR		0
> +#else
> +#define __UAPI_DEF_ETHHDR		1
> +#endif
> +
>  /* Coordinate with glibc netinet/in.h header. */
>  #if defined(_NETINET_IN_H)
>  
> @@ -182,6 +190,9 @@
>  /* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO */
>  #define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
>  
> +/* Definitions for if_ether.h */
> +#define __UAPI_DEF_ETHHDR 		1
> +
>  /* Definitions for in.h */
>  #define __UAPI_DEF_IN_ADDR		1
>  #define __UAPI_DEF_IN_IPPROTO		1
> -- 
> 2.11.0
> 
