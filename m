From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix unbalanced clk disable on driver unbind
Date: Thu, 05 Mar 2015 22:24:00 -0500 (EST)
Message-ID: <20150305.222400.773427415332956609.davem@davemloft.net>
References: <1425564569-12184-1-git-send-email-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stefan@agner.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157AbbCFDYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:24:02 -0500
In-Reply-To: <1425564569-12184-1-git-send-email-stefan@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch>
Date: Thu,  5 Mar 2015 15:09:29 +0100

> When the driver is removed (e.g. using unbind through sysfs), the
> clocks get disabled twice, once on fec_enet_close and once on
> fec_drv_remove. Since the clocks are enabled only once, this leads
> to a warning:
> 
> WARNING: CPU: 0 PID: 402 at drivers/clk/clk.c:992 clk_core_disable+0x64/0x68()
> 
> Remove the call to fec_enet_clk_enable in fec_drv_remove to balance
> the clock enable/disable calls again. This has been introduce by
> e8fcfcd5684a ("net: fec: optimize the clock management to save power").
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>

Applied, thanks.
