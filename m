From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Wed, 19 Sep 2012 13:22:48 -0700
Message-ID: <20120919132248.5fced1c7@s6510.linuxnetplumber.net>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than saving and restoring values, why not just redo the
full setup? This would also determine if the change was a result
of something outside the driver.


--- a/drivers/net/ethernet/marvell/sky2.c	2012-09-18 21:12:01.156438131 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-09-19 13:20:40.373620276 -0700
@@ -2201,6 +2201,8 @@ static void sky2_link_up(struct sky2_por
 
 	sky2_enable_rx_tx(sky2);
 
+	sky2_set_multicast(sky2->netdev);
+
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
 	netif_carrier_on(sky2->netdev);
