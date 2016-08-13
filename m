From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: remove type_check from
 dev_get_nest_level()
Date: Sat, 13 Aug 2016 15:16:34 -0700 (PDT)
Message-ID: <20160813.151634.506622667393502211.davem@davemloft.net>
References: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
	<4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
	<6dfc4b9a52ee8113e8843db32917b9e09c4d1fc4.1470951139.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	eric.dumazet@gmail.com, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbcHNIx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:53:29 -0400
In-Reply-To: <6dfc4b9a52ee8113e8843db32917b9e09c4d1fc4.1470951139.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 12 Aug 2016 16:10:33 +0200

> The idea for type_check in dev_get_nest_level() was to count the number
> of nested devices of the same type (currently, only macvlan or vlan
> devices).
> This prevented the false positive lockdep warning on configurations such
> as:
> 
> eth0 <--- macvlan0 <--- vlan0 <--- macvlan1
> 
> However, this doesn't prevent a warning on a configuration such as:
> 
> eth0 <--- macvlan0 <--- vlan0
> eth1 <--- vlan1 <--- macvlan1
> 
> In this case, all the locks end up with a nesting subclass of 1, so
> lockdep thinks that there is still a deadlock:
> 
> - in the first case we have (macvlan_netdev_addr_lock_key, 1) and then
>   take (vlan_netdev_xmit_lock_key, 1)
> - in the second case, we have (vlan_netdev_xmit_lock_key, 1) and then
>   take (macvlan_netdev_addr_lock_key, 1)
> 
> By removing the linktype check in dev_get_nest_level() and always
> incrementing the nesting depth, lockdep considers this configuration
> valid.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
