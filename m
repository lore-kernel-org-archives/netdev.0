From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH 1/1] ipv4: fix definition of FIB_TABLE_HASHSZ
Date: Wed, 13 Mar 2013 17:15:58 +0800
Message-ID: <514043CE.2080607@cn.fujitsu.com>
References: <1363164218-16316-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tingwei Liu <tingw.liu@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:23920 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab3CMJRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 05:17:48 -0400
In-Reply-To: <1363164218-16316-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2013 04:43 PM, Denis V. Lunev wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> 
> a long time ago by the commit
> 
>   commit 93456b6d7753def8760b423ac6b986eb9d5a4a95
>   Author: Denis V. Lunev <den@openvz.org>
>   Date:   Thu Jan 10 03:23:38 2008 -0800
> 
>     [IPV4]: Unify access to the routing tables.
> 
> the defenition of FIB_HASH_TABLE size has obtained wrong dependency:
> it should depend upon CONFIG_IP_MULTIPLE_TABLES (as was in the original
> code) but it was depended from CONFIG_IP_ROUTE_MULTIPATH
> 
> This patch returns the situation to the original state.
> 
> The problem was spotted by Tingwei Liu.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> CC: Tingwei Liu <tingw.liu@gmail.com>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> ---
>  include/net/ip_fib.h |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 9497be1..3b12d5c 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -152,18 +152,16 @@ struct fib_result_nl {
>  };
>  
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> -
>  #define FIB_RES_NH(res)		((res).fi->fib_nh[(res).nh_sel])
> -
> -#define FIB_TABLE_HASHSZ 2
> -
>  #else /* CONFIG_IP_ROUTE_MULTIPATH */
> -
>  #define FIB_RES_NH(res)		((res).fi->fib_nh[0])
> +#endif /* CONFIG_IP_ROUTE_MULTIPATH */
>  
> +#ifdef CONFIG_IP_ROUTE_MULTIPLE_TABLES
> +#define FIB_TABLE_HASHSZ 2
> +#else
>  #define FIB_TABLE_HASHSZ 256
> -
> -#endif /* CONFIG_IP_ROUTE_MULTIPATH */
> +#endif

With CONFIG_IP_ROUTE_MULTIPLE_TABLES defined we use a smaller FIB_TABLE_HASHSZ ?

Thanks.

>  
>  extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
>  
> 
