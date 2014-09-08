From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH net-next] netfilter: create audit records for ebtables
 replaces
Date: Mon, 8 Sep 2014 10:02:29 -0400
Message-ID: <20140908140229.GC26201@madcap2.tricolour.ca>
References: <1409907015-6145-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-audit@redhat.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754465AbaIHOIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:08:00 -0400
Content-Disposition: inline
In-Reply-To: <1409907015-6145-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/09/05, Nicolas Dichtel wrote:
> This is already done for x_tables (family AF_INET and AF_INET6), let's do it
> for AF_BRIDGE also.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

ACK.

> ---
>  net/bridge/netfilter/ebtables.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 6d69631b9f4d..4ba0c5c78778 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -26,6 +26,7 @@
>  #include <asm/uaccess.h>
>  #include <linux/smp.h>
>  #include <linux/cpumask.h>
> +#include <linux/audit.h>
>  #include <net/sock.h>
>  /* needed for logical [in,out]-dev filtering */
>  #include "../br_private.h"
> @@ -1126,6 +1127,20 @@ static int do_replace(struct net *net, const void __user *user,
>  	}
>  
>  	ret = do_replace_finish(net, &tmp, newinfo);
> +#ifdef CONFIG_AUDIT
> +	if (audit_enabled) {
> +		struct audit_buffer *ab;
> +
> +		ab = audit_log_start(current->audit_context, GFP_KERNEL,
> +				     AUDIT_NETFILTER_CFG);
> +		if (ab) {
> +			audit_log_format(ab, "table=%s family=%u entries=%u",
> +					 tmp.name, AF_BRIDGE,
> +					 tmp.nentries);
> +			audit_log_end(ab);
> +		}
> +	}
> +#endif
>  	if (ret == 0)
>  		return ret;
>  free_entries:
> -- 
> 1.9.0
> 
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
