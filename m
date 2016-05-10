From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 2/4] net-next: mediatek: fix gigabit and flow
 control advertisement
Date: Tue, 10 May 2016 12:00:03 -0400 (EDT)
Message-ID: <20160510.120003.1015276506691915584.davem@davemloft.net>
References: <1462856921-27441-1-git-send-email-john@phrozen.org>
	<1462856921-27441-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462856921-27441-3-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Tue, 10 May 2016 07:08:39 +0200

> @@ -236,7 +247,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
>  	mac->phy_dev->autoneg = AUTONEG_ENABLE;
>  	mac->phy_dev->speed = 0;
>  	mac->phy_dev->duplex = 0;
> -	mac->phy_dev->supported &= PHY_BASIC_FEATURES;
> +	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
> +				   ~SUPPORTED_Asym_Pause;

All this does is clear SUPPORTED_Asym_Pause.  Putting the other values
there, is therefore, superfluous.

I think you need to rethink through what you expect this expression to
accomplish.

Thanks.
