From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Wed, 26 Jul 2006 15:39:49 -0700 (PDT)
Message-ID: <20060726.153949.29046809.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221849.495778268@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57022
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751235AbWGZWjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:39:51 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221849.495778268@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:02 +0200

> Adds the framework to support multiple IPv6 routing tables.
> Currently all automatically generated routes are put into the
> same table. This could be changed at a later point after
> considering the produced locking overhead.
> 
> When locating routes for redirects only the main table is
> searched for now. Since policy rules will not be reversible
> it is unclear whether it makes sense to change this.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This looks good, and it seems we even fixed a bug:

> @@ -586,7 +612,7 @@ restart:
>  
>  	dst_hold(&rt->u.dst);
>  	if (nrt) {
> -		err = ip6_ins_rt(nrt, NULL, NULL, &NETLINK_CB(skb));
> +		err = ip6_ins_rt(nrt, NULL, NULL, NULL);
>  		if (!err)
>  			goto out2;
>  	}

Wow, were we corrupting the IP6CB() of input packets on every
route lookup that hit this path?

I'm probably the one who put that erroneous &NETLINK_CB(skb) there.
Sorry :)

Signed-off-by: David S. Miller <davem@davemloft.net>
