From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [redhat-lspp] ipsec acquire has security context although I a
	m not using it.
Date: Tue, 19 Sep 2006 17:58:25 -0400
Message-ID: <36282A1733C57546BE392885C0618592015730EF@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: davem@davemloft.net, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:62054 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751143AbWISV73
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 17:59:29 -0400
To: Joy Latten <latten@austin.ibm.com>, netdev@vger.kernel.org,
	redhat-lspp@redhat.com, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This doesn't look right since kzalloc would already have zeroed the
structure out. Are you sure you are getting garbage in the acquire
from the kernel? If you are, I strongly doubt that this would be the
one causing it (unless kzalloc on this arch misbehaved).
Or is this a racoon bug?

> -----Original Message-----
> From: Joy Latten [mailto:latten@austin.ibm.com]
> Sent: Tuesday, September 19, 2006 4:17 PM
> To: netdev@vger.kernel.org; redhat-lspp@redhat.com;
> selinux@tycho.nsa.gov
> Cc: davem@davemloft.net; jmorris@namei.org
> Subject: [redhat-lspp] ipsec acquire has security context 
> although I am
> not using it.
> 
> 
> 
> When using ipsec while selinux is enabled in my kernel, 
> my racoon daemon fails to establish an SA. I believe the
> ACQUIRE sent from kernel has a security context although I 
> am not using this feature with ipsec. As a result, racoon
> fails to establish the SA, because it is looking for a policy
> with security context. I noticed the security context 
> contains garbage. 
> 
> I am using a pseries, power5, ppc64 box, and it appears
> that since policy->security structure is not really initialized
> or zero'd out when not using, it is possible it may contain garbage
> on my pseries and a call such as "if (policy->security)" may 
> come back as true such that security context is included in
> my acquire message although I believe it should not be. 
> 
> Hopefully, the below patch is acceptable. I have compiled and
> tested it.
> 
> Regards,
> Joy Latten
> 
> 
> diff -urpN linux-2.6.17.orig/net/xfrm/xfrm_policy.c 
> linux-2.6.17.patch/net/xfrm/xfrm_policy.c
> --- linux-2.6.17.orig/net/xfrm/xfrm_policy.c	2006-09-19 
> 02:11:33.000000000 -0500
> +++ linux-2.6.17.patch/net/xfrm/xfrm_policy.c	2006-09-19 
> 04:33:50.000000000 -0500
> @@ -319,6 +319,7 @@ struct xfrm_policy *xfrm_policy_alloc(gf
>  		init_timer(&policy->timer);
>  		policy->timer.data = (unsigned long)policy;
>  		policy->timer.function = xfrm_policy_timer;
> +		policy->security = NULL;
>  	}
>  	return policy;
>  }
> 
> --
> redhat-lspp mailing list
> redhat-lspp@redhat.com
> https://www.redhat.com/mailman/listinfo/redhat-lspp
> 
