From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: provide stubs for ip6_set_txhash and
 ip6_make_flowlabel
Date: Tue, 08 Jul 2014 20:43:31 -0700 (PDT)
Message-ID: <20140708.204331.179733401892555162.davem@davemloft.net>
References: <1404843303-15405-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaGIDnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:43:31 -0400
In-Reply-To: <1404843303-15405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  8 Jul 2014 11:15:03 -0700

> Commit cb1ce2ef387b ("ipv6: Implement automatic flow label generation on
> transmit") introduced ip6_make_flowlabel, while commit b73c3d0e4f0e
> ("net: Save TX flow hash in sock and set in skbuf on xmit") introduced
> ip6_set_txhash.
> 
> ip6_set_tx_hash() uses sk_v6_daddr which references
> __sk_common.skc_v6_daddr from struct sock_common, which is gated with
> IS_ENABLED(CONFIG_IPV6).
> 
> ip6_make_flowlabel() uses the ipv6 member from struct net which is also
> gated with IS_ENABLED(CONFIG_IPV6).
> 
> When CONFIG_IPV6 is disabled, we will hit a build failure that looks like this
> when the compiler attempts inlining these functions:
> 
>   CC [M]  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o
> In file included from include/net/inet_sock.h:27:0,
>                  from include/net/ip.h:30,
>                  from drivers/net/ethernet/broadcom/cnic.c:37:
> include/net/ipv6.h: In function 'ip6_set_txhash':
> include/net/sock.h:327:33: error: 'struct sock_common' has no member
> named 'skc_v6_daddr'
>  #define sk_v6_daddr  __sk_common.skc_v6_daddr
>                                  ^
> include/net/ipv6.h:696:49: note: in expansion of macro 'sk_v6_daddr'
>   keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
>                                                  ^
> In file included from include/net/inetpeer.h:15:0,
>                  from include/net/route.h:28,
>                  from include/net/ip.h:31,
>                  from drivers/net/ethernet/broadcom/cnic.c:37:
> include/net/ipv6.h: In function 'ip6_make_flowlabel':
> include/net/ipv6.h:706:37: error: 'struct net' has no member named
> 'ipv6'
>   if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
>                                      ^
> 
> Fixes: cb1ce2ef387b ("ipv6: Implement automatic flow label generation on
> transmit)
> Fixes: b73c3d0e4f0e ("net: Save TX flow hash in sock and set
> in skbuf on xmit")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.

BTW, please don't chop up long lines in your commit message for things
like the "Fixes: " and other tags, thanks.
