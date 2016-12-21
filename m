From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: stmmac: dwmac-rk: make clk enablement
 first in powerup
Date: Wed, 21 Dec 2016 13:25:51 -0500 (EST)
Message-ID: <20161221.132551.414712257161308584.davem@davemloft.net>
References: <20161220161706.26505-1-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, wxt@rock-chips.com,
        briannorris@chromium.org, dianders@chromium.org,
        linux-rockchip@lists.infradead.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754277AbcLUS0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:26:06 -0500
In-Reply-To: <20161220161706.26505-1-heiko@sntech.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Stuebner <heiko@sntech.de>
Date: Tue, 20 Dec 2016 17:17:06 +0100

> Right now the dwmac-rk tries to set up the GRF-specific speed and link
> options before enabling clocks, phys etc and on previous socs this works
> because the GRF is supplied on the whole by one clock.
> 
> On the rk3399 however the GRF (General Register Files) clock-supply
> has been split into multiple clocks and while there is no specific
> grf-gmac clock like for other sub-blocks, it seems the mac-specific
> portions are actually supplied by the general mac clock.
> 
> This results in hangs on rk3399 boards if the driver is build as module.
> When built in te problem of course doesn't surface, as the clocks
> are of course still on at the stage before clock_disable_unused.
> 
> To solve this, simply move the clock enablement to the first position
> in the powerup callback. This is also a good idea in general to
> enable clocks before everything else.
> 
> Tested on rk3288, rk3368 and rk3399 the dwmac still works on all of them.
> 
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>

Applied, thank you.
