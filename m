From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers: net: cpsw: Set SECURE for dual_emac ucast
Date: Sat, 28 Feb 2015 14:49:49 -0500 (EST)
Message-ID: <20150228.144949.451713735699145008.davem@davemloft.net>
References: <1424985570-19193-1-git-send-email-george.mccollister@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, balbi@ti.com,
	lsorense@csclub.uwaterloo.ca, tony@atomide.com, mpa@pengutronix.de,
	jhovold@gmail.com, george.cherian@ti.com, tklauser@distanz.ch
To: george.mccollister@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbbB1Ttw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 14:49:52 -0500
In-Reply-To: <1424985570-19193-1-git-send-email-george.mccollister@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: George McCollister <george.mccollister@gmail.com>
Date: Thu, 26 Feb 2015 15:19:30 -0600

> Prior to this patch, sending a packet with the source MAC address of one
> of the CPSW interfaces to one of the CPSW slave ports while it's configured in
> dual_emac mode would update the port_num field of the VLAN/Unicast Address
> Table Entry. This would cause it to discard all incoming traffic addressed to
> that MAC address, essentially rendering the port useless until the ALE table is
> cleared (by starting and stopping the interface or rebooting.)
> 
> For example, if eth0 has a MAC address of 90:59:af:8f:43:e9 it will have
> an ALE table entry:
> 
> 00 00 00 00 59 90 02 30 e9 43 8f af
> (VLAN Addr vlan_id=2 unicast type=0 port_num=0 addr=90:59:af:8f:43:e9)
> 
> If you configure another device with the same MAC address and connect it
> to the first CPSW slave port and send some traffic the ALE table entry
> becomes:
> 
> 04 00 00 00 59 90 02 30 e9 43 8f af
> (VLAN Addr vlan_id=2 unicast type=0 port_num=1 addr=90:59:af:8f:43:e9)
> 
> From this point forward all incoming traffic addressed to
> 90:59:af:8f:43:e9 will be dropped.
> 
> Setting the SECURE bit for the VLAN/Unicast address table entry for each
> interface's MAC address corrects the problem.
> 
> Signed-off-by: George McCollister <george.mccollister@gmail.com>

Applied, thanks.
