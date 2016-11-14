From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: Fix lack of link transition for fixed
 PHYs
Date: Mon, 14 Nov 2016 16:40:57 -0500 (EST)
Message-ID: <20161114.164057.379572642582264115.davem@davemloft.net>
References: <20161114015036.6926-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161114015036.6926-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 13 Nov 2016 17:50:35 -0800

> Commit 52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch
> is attached") added some logic to avoid polling the fixed PHY and
> therefore invoking the adjust_link callback more than once, since this
> is a fixed PHY and link events won't be generated.
> 
> This works fine the first time, because we start with phydev->irq =
> PHY_POLL, so we call adjust_link, then we set phydev->irq =
> PHY_IGNORE_INTERRUPT and we stop polling the PHY.
> 
> Now, if we called ndo_close(), which calls both phy_stop() and does an
> explicit netif_carrier_off(), we end up with a link down. Upon calling
> ndo_open() again, despite starting the PHY state machine, we have
> PHY_IGNORE_INTERRUPT set, and we generate no link event at all, so the
> link is permanently down.
> 
> 52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch is attached")

I added the missing "Fixes: " here.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks Florian.
