From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] ipv6: fix socket multicast check
Date: Mon, 5 Mar 2012 10:45:59 -0800
Message-ID: <OFFC0CF6CF.38E7ECFD-ON882579B8.0066906E-882579B8.006715A9@us.ibm.com>
References: <1330971129-10781-1-git-send-email-ajuncu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexandru Juncu <ajuncu@ixiacom.com>, alexj@rosedu.org,
	davem@davemloft.net, Daniel Baluta <dbaluta@ixiacom.com>,
	kaber@trash.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Alexandru Juncu <ajuncu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57181 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab2CESrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 13:47:22 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 5 Mar 2012 11:47:21 -0700
In-Reply-To: <1330971129-10781-1-git-send-email-ajuncu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A socket does not need to join a multicast group to receive multicast 
packets.
Group membership is per-interface. The mc lookup here is only to apply
source filters, if any, which are per-socket.

NAK.
                                                +-DLS

netdev-owner@vger.kernel.org wrote on 03/05/2012 10:12:09 AM:

> From: Alexandru Juncu <ajuncu@ixiacom.com>
> To: netdev@vger.kernel.org, davem@davemloft.net, yoshfuji@linux-
> ipv6.org, kuznet@ms2.inr.ac.ru, kaber@trash.net
> Cc: alexj@rosedu.org, Alexandru Juncu <ajuncu@ixiacom.com>, Daniel 
> Baluta <dbaluta@ixiacom.com>
> Date: 03/05/2012 10:13 AM
> Subject: [PATCH] ipv6: fix socket multicast check
> Sent by: netdev-owner@vger.kernel.org
> 
> This fixes an issue where multicast packets are delivered for
> sockets which didn't join any multicast groups.
> 
> The issue was discovered because Hello packets duplicates were
> received in OSPFv3.
> 
> Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  net/ipv6/mcast.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index b853f06..10cc72f 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -622,7 +622,7 @@ int inet6_mc_check(struct sock *sk, const struct
> in6_addr *mc_addr,
>     }
>     if (!mc) {
>        rcu_read_unlock();
> -      return 1;
> +      return 0;
>     }
>     read_lock(&mc->sflock);
>     psl = mc->sflist;
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
