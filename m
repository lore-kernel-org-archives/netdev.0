From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 17:45:37 +0200
Message-ID: <533D8221.7010103@ahsoftware.de>
References: <533D0B09.9040602@ahsoftware.de>	<533D207E.9020909@gmail.com>	<533D790C.5000104@ahsoftware.de> <20140403.111401.1679730754008116799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	michal.simek@xilinx.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140403.111401.1679730754008116799.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.04.2014 17:14, schrieb David Miller:
> From: Alexander Holler <holler@ahsoftware.de>
> Date: Thu, 03 Apr 2014 17:06:52 +0200
>
>> But don't suggest me (or insist on) a time consuming
>
> Bisects are not time consuming, and help developers analyze your
> issue tremendously.

Hmm, compiling and booting several dozen kernels isn't time consuming? 
Then I must have done something wrong in the past.

And I wonder why I've writen descriptions at all, if nobody wants to 
understand that I already know the patch which leads to a broken network 
on that system.

If the patch is really the reason for the problem, is something totally 
different, but bisecting won't help here. Besides that I know since 4 
years that netconsole is broken on that box, it just never broke the 
network or anything else. And so I ignored it, foreseeing the necessary 
time to debug and especially describe and discuss the problem.

You see, I'm already feeling like just talking with myself. But just in 
case: After reverting patch 7cd1463, there exist a online-change to turn 
on/off the problem:

------
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c 
b/drivers/net/ethernet/marvell/mv643xx_eth.c
index e891b48..246f065 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2095,7 +2095,8 @@ static void port_start(struct mv643xx_eth_private *mp)
                 struct ethtool_cmd cmd;

                 mv643xx_eth_get_settings(mp->dev, &cmd);
-               phy_reset(mp);
+               //phy_reset(mp);
+               phy_init_hw(mp->phy);
                 mv643xx_eth_set_settings(mp->dev, &cmd);
                 phy_start(mp->phy);
         }
------

Thats basically just what the reverted patch does. Now, why should I 
still bisect?

Of course, my first assumption that the changed reset is the bug is 
wrong, it just makes the problem to appear. But that wrong assumption 
still doesn't make a bisect necessary. And it's discouraging if people 
still insist on that.

I will see if I spend the time to write down a more detailed description 
about what happens here.

Regards,

Alexander Holler
