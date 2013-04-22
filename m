From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] VXLAN: Allow L2 redirection with L3 switching
Date: Mon, 22 Apr 2013 16:10:36 -0400 (EDT)
Message-ID: <20130422.161036.274813188898687611.davem@davemloft.net>
References: <201304191036.r3JAaQ6p005959@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab3DVUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:10:38 -0400
In-Reply-To: <201304191036.r3JAaQ6p005959@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Fri, 19 Apr 2013 06:36:26 -0400

> 
> Allow L2 redirection when VXLAN L3 switching is enabled
> 
> This patch restricts L3 switching to destination MAC addresses that are
> marked as routers in order to allow virtual IP appliances that do L2
> redirection to function with VXLAN L3 switching enabled.
> 
> We use L3 switching on VXLAN networks to avoid extra hops when the nominal
> router for cross-subnet traffic for a VM is remote and the ultimate
> destination may be local, or closer to the local node. Currently, the
> destination IP address takes precedence over the MAC address in all cases.
> Some network appliances receive packets for a virtualized IP address and
> redirect by changing the destination MAC address (only) to be the final
> destination for packet processing. VXLAN tunnel endpoints with L3 switching
> enabled may then overwrite this destination MAC address based on the packet IP
> address, resulting in potential loops and, at least, breaking L2 redirections
> that travel through tunnel endpoints.
> 
> This patch limits L3 switching to the intended case where the original
> destination MAC address is a next-hop router and relies on the destination
> MAC address for all other cases, thus allowing L2 redirection and L3 switching
> to coexist peacefully.
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks David.

Amerigo, I know this conflicts with your ipv6 work, but I'm not making
David wait while you sort out all of those ipv6 symbol export build
failures.
