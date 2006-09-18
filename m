From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/7] secid reconciliation-v02: Invoke LSM hook for inbound
 traffic
Date: Mon, 18 Sep 2006 14:05:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181404050.5976@d.namei>
References: <45019F62.7000305@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:697 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751872AbWIRSFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:05:02 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F62.7000305@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> -static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff
> *skb)
> -{
> -	return xfrm_policy_check(sk, dir, skb, AF_INET6);
> +	if (sk && sk->sk_policy[XFRM_POLICY_IN])
> +		ret = __xfrm_policy_check(sk, dir, skb, family);
> +	else
> +		ret = (!xfrm_policy_count[dir] && !skb->sp) ||
> +		      (skb->dst->flags & DST_NOPOLICY) ||
> +		      __xfrm_policy_check(sk, dir, skb, family);
> +
> +#ifdef CONFIG_SECURITY_NETWORK
> +	if (ret)
> +		ret = security_skb_policy_check(skb, family);
> +#endif /* CONFIG_SECURITY_NETWORK */

Why is this code ifdef'd when the function is conditionally compiled?

> {
> +#ifdef CONFIG_SECURITY_NETWORK
> +	return security_skb_policy_check(skb, family);
> +#else
> 	return 1;
> +#endif /* CONFIG_SECURITY_NETWORK */

Ditto.



-- 
James Morris
<jmorris@namei.org>
