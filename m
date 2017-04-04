From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix race condition during
 open()
Date: Tue, 04 Apr 2017 10:33:48 -0700 (PDT)
Message-ID: <20170404.103348.2265460653101200539.davem@davemloft.net>
References: <509439ff3e756ea1dade2738e305f08fc7920650.1491220439.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932178AbdDDRdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:33:50 -0400
In-Reply-To: <509439ff3e756ea1dade2738e305f08fc7920650.1491220439.git.nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sekhar Nori <nsekhar@ti.com>
Date: Mon, 3 Apr 2017 17:34:28 +0530

> TI's cpsw driver handles both OF and non-OF case for phy
> connect. Unfortunately of_phy_connect() returns NULL on
> error while phy_connect() returns ERR_PTR().
> 
> To handle this, cpsw_slave_open() overrides the return value
> from phy_connect() to make it NULL or error.
> 
> This leaves a small window, where cpsw_adjust_link() may be
> invoked for a slave while slave->phy pointer is temporarily
> set to -ENODEV (or some other error) before it is finally set
> to NULL.
> 
> _cpsw_adjust_link() only handles the NULL case, and an oops
> results when ERR_PTR() is seen by it.
> 
> Note that cpsw_adjust_link() checks PHY status for each
> slave whenever it is invoked. It can so happen that even
> though phy_connect() for a given slave returns error,
> _cpsw_adjust_link() is still called for that slave because
> the link status of another slave changed.
> 
> Fix this by using a temporary pointer to store return value
> of {of_}phy_connect() and do a one-time write to slave->phy.
> 
> Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Reported-by: Yan Liu <yan-liu@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>

Applied, thank you.
