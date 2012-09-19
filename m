From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Wed, 19 Sep 2012 22:38:25 +0200
Message-ID: <20120919203825.GA1460@minipsycho.orion>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
 <20120919132248.5fced1c7@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120919132248.5fced1c7@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Sep 19, 2012 at 10:22:48PM CEST, shemminger@vyatta.com wrote:
>Rather than saving and restoring values, why not just redo the
>full setup? This would also determine if the change was a result
>of something outside the driver.

You cannot call sky2_set_multicast() directly here. It is called from
__dev_set_rx_mode(). You would have to take at lease netif_addr_lock()
here. I think that clearer is to remember computed value....

>
>
>--- a/drivers/net/ethernet/marvell/sky2.c	2012-09-18 21:12:01.156438131 -0700
>+++ b/drivers/net/ethernet/marvell/sky2.c	2012-09-19 13:20:40.373620276 -0700
>@@ -2201,6 +2201,8 @@ static void sky2_link_up(struct sky2_por
> 
> 	sky2_enable_rx_tx(sky2);
> 
>+	sky2_set_multicast(sky2->netdev);
>+
> 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
> 
> 	netif_carrier_on(sky2->netdev);
