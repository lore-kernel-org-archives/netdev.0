From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 7/7] rtnetlink: rtnl_have_link_slave_info doesn't
 need rtnl
Date: Thu, 21 Sep 2017 11:24:49 -0600
Message-ID: <b645a22f-9153-b327-8995-2b140cff59a0@gmail.com>
References: <20170921165902.10746-1-fw@strlen.de>
 <20170921165902.10746-8-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34788 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752782AbdIURYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:24:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id g65so2736858pfe.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 10:24:51 -0700 (PDT)
In-Reply-To: <20170921165902.10746-8-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/17 10:59 AM, Florian Westphal wrote:
> @@ -539,6 +543,8 @@ static int rtnl_link_slave_info_fill(struct sk_buff *skb,
>  	struct nlattr *slave_data;
>  	int err;
>  
> +	ASSERT_RTNL();
> +
>  	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
>  	if (!master_dev)
>  		return 0;
> @@ -570,6 +576,8 @@ static int rtnl_link_info_fill(struct sk_buff *skb,
>  	struct nlattr *data;
>  	int err;
>  
> +	ASSERT_RTNL();
> +
>  	if (!ops)
>  		return 0;
>  	if (nla_put_string(skb, IFLA_INFO_KIND, ops->kind) < 0)
> @@ -600,6 +608,8 @@ static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
>  	struct nlattr *linkinfo;
>  	int err = -EMSGSIZE;
>  
> +	ASSERT_RTNL();
> +
>  	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
>  	if (linkinfo == NULL)
>  		goto out;
> 


Since rtnl_link_slave_info_fill and rtnl_link_info_fill are only called
by rtnl_link_fill and rtnl_link_fill is only called rtnl_fill_ifinfo
which as the ASSERT_RTNL why add to these lower functions as well?
