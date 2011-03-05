From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: tun routing is broken
Date: Sat, 05 Mar 2011 09:17:24 +0100
Message-ID: <4D71F194.9010402@suse.cz>
References: <20110304.010603.104076956.davem@davemloft.net>	<4D70B2DC.2000005@gmail.com>	<4D71EE86.6030309@suse.cz> <20110305.001022.183044112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	netdev@vger.kernel.org, maxk@qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47087 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1CEIR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 03:17:28 -0500
In-Reply-To: <20110305.001022.183044112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2011 09:10 AM, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Sat, 05 Mar 2011 09:04:22 +0100
> 
>> Ok, so I booted the new kernel, and tun is broken there completely. If I
>> try to ping a vpn peer:
> 
> -mm tree is missing this fix which went in yesterday.  Please if
> you are going to be testing networking a lot, test against net-next-2.6
> instead of Andrew's tree which invariable lags behind:

I'm not testing networking, I'm just using my desktop :). (And
next/master is mostly unusable for these needs. In comparison to mmotm
which is some kind of a "release".)

> --------------------
> ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.

It would be great to have a References: tag or better changelog. Then I
would give the commit a shot. The way it is I ignored it when looking at
next/master inside net/ipv4/ changes for commits to test.

Going to boot with this change.

> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/devinet.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 9038928..ff53860 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -111,7 +111,7 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
>  
>  static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
>  {
> -	unsigned int hash = inet_addr_hash(net, ifa->ifa_address);
> +	unsigned int hash = inet_addr_hash(net, ifa->ifa_local);
>  
>  	spin_lock(&inet_addr_hash_lock);
>  	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
> @@ -146,7 +146,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
>  
>  		if (!net_eq(dev_net(dev), net))
>  			continue;
> -		if (ifa->ifa_address == addr) {
> +		if (ifa->ifa_local == addr) {
>  			result = dev;
>  			break;
>  		}

thanks,
-- 
js
suse labs
