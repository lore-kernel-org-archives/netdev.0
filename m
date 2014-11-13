From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/smsc911x: Fix rare soft reset timeout issue
 due to PHY power-down mode
Date: Thu, 13 Nov 2014 14:38:12 -0500 (EST)
Message-ID: <20141113.143812.427969170493393832.davem@davemloft.net>
References: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: al.kochet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933615AbaKMTiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:38:15 -0500
In-Reply-To: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Kochetkov <al.kochet@gmail.com>
Date: Thu, 13 Nov 2014 05:26:19 +0400

> The patch affect SMSC LAN generation 4 chips with integrated PHY (LAN9221).
> 
> It is possible that PHY could enter power-down mode (ENERGYON clear),
> between ENERGYON bit check in smsc911x_phy_disable_energy_detect and SRST
> bit set in smsc911x_soft_reset. This could happen, for example, if someone
> disconnect ethernet cable between the checks. The PHY in a power-down mode
> would prevent the MAC portion of chip to be software reseted.
> 
> Initially found by code review, confirmed later using test case.
> 
> This is low probability issue, and in order to reproduce it you have to
> run the script:
> 
> while true; do
> 	ifconfig eth0 down
> 	ifconfig eth0 up || break
> done
> 
> While the script is running you have to plug/unplug ethernet cable many
> times (using gpio controlled ethernet switch, for example) until get:
> 
> [ 4516.477783] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [ 4516.512207] smsc911x smsc911x.0: eth0: SMSC911x/921x identified at 0xce006000, IRQ: 336
> [ 4516.524658] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [ 4516.559082] smsc911x smsc911x.0: eth0: SMSC911x/921x identified at 0xce006000, IRQ: 336
> [ 4516.571990] ADDRCONF(NETDEV_UP): eth0: link is not ready
> ifconfig: SIOCSIFFLAGS: Input/output error
> 
> The patch was reviewed by Steve Glendinning and Microchip Team.
> 
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> Acked-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
