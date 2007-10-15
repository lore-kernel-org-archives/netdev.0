From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: SELINUX fixup for netfilter hook changes
Date: Tue, 16 Oct 2007 00:20:29 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0710160020130.21052@us.intercode.com.au>
References: <20071015.025909.77039408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:39974 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751173AbXJOOVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:21:00 -0400
In-Reply-To: <20071015.025909.77039408.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007, David Miller wrote:

> 
> I just noticed a warning for this in my allmodconfig build,
> so I checked in the obvious fix.

Thanks.

> 
> commit d0a23b19f552c4fd0126d903078ea5ceca968617
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Mon Oct 15 02:58:25 2007 -0700
> 
>     [SELINUX]: Update for netfilter ->hook() arg changes.
>     
>     They take a "struct sk_buff *" instead of a "struct sk_buff **" now.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 3c3fff3..cf76150 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3932,7 +3932,7 @@ out:
>  }
>  
>  static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
> -                                              struct sk_buff **pskb,
> +                                              struct sk_buff *skb,
>                                                const struct net_device *in,
>                                                const struct net_device *out,
>                                                int (*okfn)(struct sk_buff *),
> @@ -3941,7 +3941,6 @@ static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
>  	char *addrp;
>  	int len, err = 0;
>  	struct sock *sk;
> -	struct sk_buff *skb = *pskb;
>  	struct avc_audit_data ad;
>  	struct net_device *dev = (struct net_device *)out;
>  	struct sk_security_struct *sksec;
> @@ -3977,23 +3976,23 @@ out:
>  }
>  
>  static unsigned int selinux_ipv4_postroute_last(unsigned int hooknum,
> -						struct sk_buff **pskb,
> +						struct sk_buff *skb,
>  						const struct net_device *in,
>  						const struct net_device *out,
>  						int (*okfn)(struct sk_buff *))
>  {
> -	return selinux_ip_postroute_last(hooknum, pskb, in, out, okfn, PF_INET);
> +	return selinux_ip_postroute_last(hooknum, skb, in, out, okfn, PF_INET);
>  }
>  
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  
>  static unsigned int selinux_ipv6_postroute_last(unsigned int hooknum,
> -						struct sk_buff **pskb,
> +						struct sk_buff *skb,
>  						const struct net_device *in,
>  						const struct net_device *out,
>  						int (*okfn)(struct sk_buff *))
>  {
> -	return selinux_ip_postroute_last(hooknum, pskb, in, out, okfn, PF_INET6);
> +	return selinux_ip_postroute_last(hooknum, skb, in, out, okfn, PF_INET6);
>  }
>  
>  #endif	/* IPV6 */
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
