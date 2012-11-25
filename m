From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: in balance-rr mode, set curr_active_slave
 only if it is up
Date: Sun, 25 Nov 2012 16:03:53 -0500 (EST)
Message-ID: <20121125.160353.581132618272394748.davem@davemloft.net>
References: <20121122125202.14252C35B8@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121122125202.14252C35B8@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 22 Nov 2012 13:48:39 +0100

> If all slaves of a balance-rr bond with ARP monitor are enslaved
> with down link state, bond keeps down state even after slaves
> go up.
> 
> This is caused by bond_enslave() setting curr_active_slave to
> first slave not taking into account its link state. As
> bond_loadbalance_arp_mon() uses curr_active_slave to identify
> whether slave's down->up transition should update bond's link
> state, bond stays down even if slaves are up (until first slave
> goes from up to down at least once).
> 
> Before commit f31c7937 "bonding: start slaves with link down for
> ARP monitor", this was masked by slaves always starting in UP
> state with ARP monitor (and MII monitor not relying on
> curr_active_slave being NULL if there is no slave up).
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Jay/Andy please review.
