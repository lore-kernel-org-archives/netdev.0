From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] net: stmmac: socfpga: Remove re-registration of
 reset controller
Date: Sun, 24 Apr 2016 14:40:57 -0400 (EDT)
Message-ID: <20160424.144057.513556416511185194.davem@davemloft.net>
References: <1461240710-5381-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, mgerlach@opensource.altera.com,
	dinguyen@opensource.altera.com
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbcDXSlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:41:02 -0400
In-Reply-To: <1461240710-5381-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Thu, 21 Apr 2016 14:11:50 +0200

> Both socfpga_dwmac_parse_data() in dwmac-socfpga.c and stmmac_dvr_probe()
> in stmmac_main.c functions call devm_reset_control_get() to register an
> reset controller for the stmmac. This results in an attempt to register
> two reset controllers for the same non-shared reset line.
> 
> The first attempt to register the reset controller works fine. The second
> attempt fails with warning from the reset controller core, see below.
> The warning is produced because the reset line is non-shared and thus
> it is allowed to have only up-to one reset controller associated with
> that reset line, not two or more.
> 
> The solution has multiple parts. First, the original socfpga_dwmac_init()
> is tweaked to use reset controller pointer from the stmmac_priv (private
> data of the stmmac core) instead of the local instance, which was used
> before. The local re-registration of the reset controller is removed.
> 
> Next, the socfpga_dwmac_init() is moved after stmmac_dvr_probe() in the
> probe function. This order is legal according to Altera and it makes the
> code much easier, since there is no need to temporarily register and
> unregister the reset controller ; the reset controller is already registered
> by the stmmac_dvr_probe().
> 
> Finally, plat_dat->exit and socfpga_dwmac_exit() is no longer necessary,
> since the functionality is already performed by the stmmac core.
 ...
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Matthew Gerlach <mgerlach@opensource.altera.com>
> Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
> Cc: David S. Miller <davem@davemloft.net>

Applied, thanks.
