From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 4/7] secid reconciliation-v03: Invoke LSM hook for outbound
 traffic
Date: Fri, 29 Sep 2006 03:32:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609290324050.1650@d.namei>
References: <451C85E2.2030201@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:54676 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161473AbWI2Hcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:32:51 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <451C85E2.2030201@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006, Venkat Yekkirala wrote:

> +		if (connsecmark)
> +			if (*connsecmark != skb->secmark) {
>  				*connsecmark = skb->secmark;
> +			}

Please remove the braces if re-submitting.

> +printk(KERN_ERR "IN HOOK (%d) (%u) (%u)\n", hooknum, skb->secmark, *psecmark);\

Please remove debugging (here and elsewhere).



> +		/* Set secmark on inbound and filter it on outbound */
> +		if ((target->family == AF_INET &&
> +			(hooknum == NF_IP_POST_ROUTING ||
> +			 hooknum == NF_IP_LOCAL_OUT ||
> +			 hooknum == NF_IP_FORWARD)) ||
> +		    (target->family == AF_INET6 &&
> +			(hooknum == NF_IP6_POST_ROUTING ||
> +			 hooknum == NF_IP6_LOCAL_OUT ||
> +			 hooknum == NF_IP6_FORWARD))) {

I think this should be a separate helper function, so the logic can be 
changed/evaluated in isolation (preferred, but not a blocker).

> +		secmark_save(skb, hooknum, target);

It seems that the target parameter is not needed.


> +		return secmark_restore(skb, hooknum, in, target);

Please pass a family parameter instead of target.



-- 
James Morris
<jmorris@namei.org>
