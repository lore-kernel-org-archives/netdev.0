From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for outbound
 traffic
Date: Mon, 18 Sep 2006 14:19:54 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181418310.5976@d.namei>
References: <45019F66.20603@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:36770 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751876AbWIRST4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:19:56 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F66.20603@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> @@ -114,6 +128,9 @@ static struct xt_target xt_connsecmark_t
> 		.target		= target,
> 		.targetsize	= sizeof(struct xt_connsecmark_target_info),
> 		.table		= "mangle",
> +		.hooks		= (1 << NF_IP_LOCAL_IN) |
> +				  (1 << NF_IP_FORWARD) |
> +				  (1 << NF_IP_POST_ROUTING),

Why have you added constraints on the hooks?

This breaks a bunch of things.


> @@ -123,6 +140,9 @@ static struct xt_target xt_connsecmark_t
> 		.target		= target,
> 		.targetsize	= sizeof(struct xt_connsecmark_target_info),
> 		.table		= "mangle",
> +		.hooks		= (1 << NF_IP6_LOCAL_IN) |
> +				  (1 << NF_IP6_FORWARD) |
> +				  (1 << NF_IP6_POST_ROUTING),
> 		.me		= THIS_MODULE,

Ditto...

> @@ -119,6 +129,9 @@ static struct xt_target xt_secmark_targe
> 		.target		= target,
> 		.targetsize	= sizeof(struct xt_secmark_target_info),
> 		.table		= "mangle",
> +		.hooks		= (1 << NF_IP_LOCAL_IN) |
> +				  (1 << NF_IP_FORWARD) |
> +				  (1 << NF_IP_POST_ROUTING),
> 		.me		= THIS_MODULE,
> 	},
> 	{
> @@ -128,6 +141,9 @@ static struct xt_target xt_secmark_targe
> 		.target		= target,
> 		.targetsize	= sizeof(struct xt_secmark_target_info),
> 		.table		= "mangle",
> +		.hooks		= (1 << NF_IP6_LOCAL_IN) |
> +				  (1 << NF_IP6_FORWARD) |
> +				  (1 << NF_IP6_POST_ROUTING),
> 		.me		= THIS_MODULE,
> 	},
> };
> 

-- 
James Morris
<jmorris@namei.org>
