From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Sat, 05 Aug 2006 11:00:36 +0200
Message-ID: <44D45E34.9030607@trash.net>
References: <20060804102308.711837665@postel.suug.ch> <20060804102636.322297243@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090706000803050307030100"
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42650 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422767AbWHEJAh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 05:00:37 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060804102636.322297243@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090706000803050307030100
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:
> Index: net-2.6.19/net/ipv6/route.c
> ===================================================================
> --- net-2.6.19.orig/net/ipv6/route.c
> +++ net-2.6.19/net/ipv6/route.c
> @@ -1750,6 +1843,10 @@ static int rt6_fill_node(struct sk_buff 
>  	rtm->rtm_dst_len = rt->rt6i_dst.plen;
>  	rtm->rtm_src_len = rt->rt6i_src.plen;
>  	rtm->rtm_tos = 0;
> +	if (rt->rt6i_table)
> +		rtm->rtm_table = rt->rt6i_table->tb6_id;
> +	else
> +		rtm->rtm_table = RT6_TABLE_UNSPEC;
>  	rtm->rtm_table = RT_TABLE_MAIN;


This looks like a mistake, the table ID is overwritten again.


Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------090706000803050307030100
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d5c39c4..3ea6db9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1898,7 +1898,6 @@ static int rt6_fill_node(struct sk_buff 
 		rtm->rtm_table = rt->rt6i_table->tb6_id;
 	else
 		rtm->rtm_table = RT6_TABLE_UNSPEC;
-	rtm->rtm_table = RT_TABLE_MAIN;
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))

--------------090706000803050307030100--
