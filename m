From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mvneta: fix failed to suspend if WOL is
 enabled
Date: Mon, 17 Apr 2017 13:48:09 -0400 (EDT)
Message-ID: <20170417.134809.952428725665734201.davem@davemloft.net>
References: <20170414110732.3100-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56050 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbdDQRsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:48:11 -0400
In-Reply-To: <20170414110732.3100-1-jszhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jisheng Zhang <jszhang@marvell.com>
Date: Fri, 14 Apr 2017 19:07:32 +0800

> Recently, suspend/resume and WOL support are added into mvneta driver.
> If we enable WOL, then we get some error as below on Marvell BG4CT
> platforms during suspend:
> 
> [  184.149723] dpm_run_callback(): mdio_bus_suspend+0x0/0x50 returns -16
> [  184.149727] PM: Device f7b62004.mdio-mi:00 failed to suspend: error -16
> 
> -16 means -EBUSY, phy_suspend() will return -EBUSY if it finds the
> device has WOL enabled.
> 
> We fix this issue by properly setting the netdev's power.can_wakeup
> and power.wakeup, i.e
> 
> 1. in mvneta_mdio_probe(), call device_set_wakeup_capable() to set
> power.can_wakeup if the phy support WOL.
> 
> 2. in mvneta_ethtool_set_wol(), call device_set_wakeup_enable() to
> set power.wakeup if WOL has been successfully enabled in phy.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Applied.
