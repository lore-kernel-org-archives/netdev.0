From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 2/3] bridge br_multicast: Make functions
 less ipv4 dependent.
Date: Mon, 29 Mar 2010 09:12:32 -0700
Message-ID: <20100329091232.50eae040@nehalam>
References: <201003291101.o2TB1R0W006599@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54628 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab0C2Q3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 12:29:06 -0400
In-Reply-To: <201003291101.o2TB1R0W006599@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Mar 2010 20:01:27 +0900
YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> Introduce struct br_ip{} to store ip address and protocol
> and make functions more generic so that we can support
> both IPv4 and IPv6 with less pain.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/bridge/br_multicast.c |  181 +++++++++++++++++++++++++++++++--------------
>  net/bridge/br_private.h   |   12 +++-
>  2 files changed, 135 insertions(+), 58 deletions(-)
> 
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 9f0c4f0..5338574 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -27,48 +27,86 @@
>  
>  #include "br_private.h"
>  
> -static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
> +#define IP4_BRIP(ip)	(struct br_ip) {			\
> +				.u.ip4 = ip,			\
> +				.proto = htons(ETH_P_IP),	\
> +			}
> +

Too messy with macros, I will fix.


-- 
