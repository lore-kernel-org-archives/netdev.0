From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix ASSERT_RTNL() warning
 during resume
Date: Wed, 30 Nov 2016 14:59:36 -0500 (EST)
Message-ID: <20161130.145936.1357519815495012632.davem@davemloft.net>
References: <20161129222703.10908-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        ivan.khoronzhuk@linaro.org, d-gerlach@ti.com
To: grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754786AbcK3T7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:59:38 -0500
In-Reply-To: <20161129222703.10908-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Tue, 29 Nov 2016 16:27:03 -0600

> netif_set_real_num_tx/rx_queues() are required to be called with rtnl_lock
> taken, otherwise ASSERT_RTNL() warning will be triggered - which happens
> now during System resume from suspend:
> cpsw_resume()
> |- cpsw_ndo_open()
>   |- netif_set_real_num_tx/rx_queues()
>      |- ASSERT_RTNL();
> 
> Hence, fix it by surrounding cpsw_ndo_open() by rtnl_lock/unlock() calls.
> 
> Cc: Dave Gerlach <d-gerlach@ti.com>
> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Fixes: commit e05107e6b747 ("net: ethernet: ti: cpsw: add multi queue support")
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied.
