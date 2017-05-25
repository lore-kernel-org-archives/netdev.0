From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: ipv4: refactor
 __ip_route_output_key_hash
Date: Wed, 24 May 2017 19:10:28 -0600
Message-ID: <692be183-cb75-fe33-605b-e458b10ef240@gmail.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
 <1495649951-30417-2-git-send-email-roopa@cumulusnetworks.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F93D54F8DF@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>
To: "Rosen, Rami" <rami.rosen@intel.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36132 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161347AbdEYBKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 21:10:35 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so35508386pfb.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 18:10:35 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F93D54F8DF@HASMSX110.ger.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/17 1:33 PM, Rosen, Rami wrote:
> Hi, Rupa /David Ahern,
> 
> First, thanks for this patch set!
> 
> Second, it seems to me that something might be incorrect here.
> 
> You have these additions in this patch  (1/8):
> ...
> +struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *flp,
> +					    const struct sk_buff *skb,
> +					    struct fib_result *res);
> ...
> +struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
> +					const struct sk_buff *skb)
> +{
> +	struct fib_result res;
> +	struct rtable *rth;
> +
> +	res.tclassid	= 0;
> +	res.fi		= NULL;
> +	res.table	= NULL;
> +
> +	rcu_read_lock();
> +	rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
>  	rcu_read_unlock();
> +
>  	return rth;
>  }
> -EXPORT_SYMBOL_GPL(__ip_route_output_key_hash);
> +EXPORT_SYMBOL_GPL(ip_route_output_key_hash);
>  
> 
> So the third parameter to ip_route_output_key_hash_rcu() should be skb*, and the fourth parameter should be fib_result *. However, you do not pass the skb parameter 
> when calling ip_route_output_key_hash_rcu() in 
> ip_route_output_key_hash()  (in fact you don't use it at all),  and you pass mp_hash as the fourth parameter.

Yep, it's a problem with the forward port of the first round of patches.

Roopa: in include/net/route.h, __ip_route_output_key_hash should be
removed as well.
