From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 2/2] net, netns_xt: shrink netns_xt members
Date: Thu, 9 Jul 2009 12:55:21 -0700
Message-ID: <20090709125521.4bacfd47@nehalam>
References: <20090704061156.658235360@openvz.org>
	<20090704062321.034802084@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36999 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756050AbZGIUl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 16:41:56 -0400
In-Reply-To: <20090704062321.034802084@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 04 Jul 2009 10:11:58 +0400
Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> In case if kernel was compiled without ebtables support
> there is no need to keep ebt_table pointers in netns_xt
> structure.
> 
> Make it config dependent.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
> 
> Probably GCC will authomatically shrink the structure
> if the members are not in use. Please review.
> 
>  include/net/netns/x_tables.h |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: linux-2.6.git/include/net/netns/x_tables.h
> =====================================================================
> --- linux-2.6.git.orig/include/net/netns/x_tables.h
> +++ linux-2.6.git/include/net/netns/x_tables.h
> @@ -8,8 +8,11 @@ struct ebt_table;
>  
>  struct netns_xt {
>  	struct list_head tables[NFPROTO_NUMPROTO];
> +#if defined(CONFIG_BRIDGE_NF_EBTABLES) || \
> +    defined(CONFIG_BRIDGE_NF_EBTABLES_MODULE)
>  	struct ebt_table *broute_table;
>  	struct ebt_table *frame_filter;
>  	struct ebt_table *frame_nat;
> +#endif
>  };
>  #endif
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
