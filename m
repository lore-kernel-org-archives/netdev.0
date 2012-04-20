From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 12/19] net neighbour:  Convert to use register_net_sysctl
Date: Fri, 20 Apr 2012 09:21:47 +0400
Message-ID: <4F90F26B.3090906@parallels.com>
References: <m1aa27ia6h.fsf@fess.ebiederm.org> <m1ehrjfg2s.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17084 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395Ab2DTFWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 01:22:13 -0400
In-Reply-To: <m1ehrjfg2s.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -2925,19 +2924,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
>  {
>  	struct neigh_sysctl_table *t;
>  	const char *dev_name_source = NULL;
> -
> -#define NEIGH_CTL_PATH_ROOT	0
> -#define NEIGH_CTL_PATH_PROTO	1
> -#define NEIGH_CTL_PATH_NEIGH	2
> -#define NEIGH_CTL_PATH_DEV	3
> -
> -	struct ctl_path neigh_path[] = {
> -		{ .procname = "net",	 },
> -		{ .procname = "proto",	 },
> -		{ .procname = "neigh",	 },
> -		{ .procname = "default", },
> -		{ },
> -	};
> +	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];

Why two IFNAMSIZ-es? One is for the dev->name, but the other one is not.
Is it just for not having any other better constant at hands?

>  	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
>  	if (!t)
