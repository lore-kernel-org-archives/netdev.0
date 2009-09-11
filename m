From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] ucc_geth: Fix hangs after switching from full
 to half duplex
Date: Fri, 11 Sep 2009 12:19:58 -0700 (PDT)
Message-ID: <20090911.121958.06510883.davem@davemloft.net>
References: <20090910194053.GA24363@oksana.dev.rtsoft.ru>
	<20090910210935.GA26037@oksana.dev.rtsoft.ru>
	<20090910214812.GA30564@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scottwood@freescale.com, netdev@vger.kernel.org,
	afleming@freescale.com, timur@freescale.com,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755785AbZIKTTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:19:42 -0400
In-Reply-To: <20090910214812.GA30564@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Fri, 11 Sep 2009 01:48:12 +0400

> MPC8360 QE UCC ethernet controllers hang when changing link duplex
> under a load (a bit of NFS activity is enough).
> 
>   PHY: mdio@e0102120:00 - Link is Up - 1000/Full
>   sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
>   PHY: mdio@e0102120:00 - Link is Down
>   PHY: mdio@e0102120:00 - Link is Up - 100/Half
>   NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
>   ------------[ cut here ]------------
>   Badness at c01fcbd0 [verbose debug info unavailable]
>   NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
>   ...
> 
> The cure is to disable the controller before changing speed/duplex
> and enable it afterwards.
> 
> Though, disabling the controller might take quite a while, so we
> better not grab any spinlocks in adjust_link(). Instead, we quiesce
> the driver's activity, and only then disable the controller.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
