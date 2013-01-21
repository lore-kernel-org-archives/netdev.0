From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 1/2] mcast: define and use MRT[6]_MAX in ip[6]_mroute_opt()
Date: Mon, 21 Jan 2013 09:16:14 -0500
Message-ID: <OF6FF1EE54.813A59C8-ON87257AFA.004E5ADE-85257AFA.004E632A@us.ibm.com>
References: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com> <1358528378-2110-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47901 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab3AUOQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 09:16:41 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 21 Jan 2013 07:16:40 -0700
In-Reply-To: <1358528378-2110-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: David L Stevens <dlstevens@us.ibm.com>

netdev-owner@vger.kernel.org wrote on 01/18/2013 11:59:37 AM:

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: 01/18/2013 12:10 PM
> Subject: [PATCH net-next 1/2] mcast: define and use MRT[6]_MAX in ip
> [6]_mroute_opt()
> Sent by: netdev-owner@vger.kernel.org
> 
> This will ease further addition of new MRT[6]_* values and avoid to 
update
> in6.h each time.
> Note that we reduce the maximum value from 210 to 209, but 210 does not 
match
> any known value in ip[6]_mroute_setsockopt().
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/linux/mroute.h       |  2 +-
>  include/linux/mroute6.h      |  2 +-
>  include/uapi/linux/in6.h     | 15 ++++-----------
>  include/uapi/linux/mroute.h  |  1 +
>  include/uapi/linux/mroute6.h |  1 +
>  5 files changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
> index ea00d91..79aaa9f 100644
> --- a/include/linux/mroute.h
> +++ b/include/linux/mroute.h
> @@ -9,7 +9,7 @@
>  #ifdef CONFIG_IP_MROUTE
>  static inline int ip_mroute_opt(int opt)
>  {
> -   return (opt >= MRT_BASE) && (opt <= MRT_BASE + 10);
> +   return (opt >= MRT_BASE) && (opt <= MRT_MAX);
>  }
>  #else
>  static inline int ip_mroute_opt(int opt)
> diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
> index a223561..66982e7 100644
> --- a/include/linux/mroute6.h
> +++ b/include/linux/mroute6.h
> @@ -10,7 +10,7 @@
>  #ifdef CONFIG_IPV6_MROUTE
>  static inline int ip6_mroute_opt(int opt)
>  {
> -   return (opt >= MRT6_BASE) && (opt <= MRT6_BASE + 10);
> +   return (opt >= MRT6_BASE) && (opt <= MRT6_MAX);
>  }
>  #else
>  static inline int ip6_mroute_opt(int opt)
> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
> index 5673b97..53b1d56 100644
> --- a/include/uapi/linux/in6.h
> +++ b/include/uapi/linux/in6.h
> @@ -259,17 +259,10 @@ struct in6_flowlabel_req {
> 
>  /*
>   * Multicast Routing:
> - * see include/linux/mroute6.h.
> + * see include/uapi/linux/mroute6.h.
>   *
> - * MRT6_INIT         200
> - * MRT6_DONE         201
> - * MRT6_ADD_MIF         202
> - * MRT6_DEL_MIF         203
> - * MRT6_ADD_MFC         204
> - * MRT6_DEL_MFC         205
> - * MRT6_VERSION         206
> - * MRT6_ASSERT         207
> - * MRT6_PIM         208
> - * (reserved)         209
> + * MRT6_BASE         200
> + * ...
> + * MRT6_MAX
>   */
>  #endif /* _UAPI_LINUX_IN6_H */
> diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
> index 1692999..1c11004 100644
> --- a/include/uapi/linux/mroute.h
> +++ b/include/uapi/linux/mroute.h
> @@ -26,6 +26,7 @@
>  #define MRT_ASSERT   (MRT_BASE+7)   /* Activate PIM assert mode      */
>  #define MRT_PIM      (MRT_BASE+8)   /* enable PIM code         */
>  #define MRT_TABLE   (MRT_BASE+9)   /* Specify mroute table ID      */
> +#define MRT_MAX      (MRT_BASE+9)
> 
>  #define SIOCGETVIFCNT   SIOCPROTOPRIVATE   /* IP protocol privates */
>  #define SIOCGETSGCNT   (SIOCPROTOPRIVATE+1)
> diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
> index 3e89b5e..c206ae3 100644
> --- a/include/uapi/linux/mroute6.h
> +++ b/include/uapi/linux/mroute6.h
> @@ -26,6 +26,7 @@
>  #define MRT6_ASSERT   (MRT6_BASE+7)   /* Activate PIM assert mode */
>  #define MRT6_PIM   (MRT6_BASE+8)   /* enable PIM code         */
>  #define MRT6_TABLE   (MRT6_BASE+9)   /* Specify mroute table ID      */
> +#define MRT6_MAX   (MRT6_BASE+9)
> 
>  #define SIOCGETMIFCNT_IN6   SIOCPROTOPRIVATE   /* IP protocol privates 
*/
>  #define SIOCGETSGCNT_IN6   (SIOCPROTOPRIVATE+1)
> -- 
> 1.8.0.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
