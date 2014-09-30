From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 10/10] r8169:call "rtl8168_driver_start"
 "rtl8168_driver_stop" only when dash is enabled
Date: Tue, 30 Sep 2014 16:46:08 -0400 (EDT)
Message-ID: <20140930.164608.2229644163648293678.davem@davemloft.net>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
	<1412089230-10208-10-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-10-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chun-Hao Lin <hau@realtek.com>
Date: Tue, 30 Sep 2014 23:00:30 +0800

> These two functions are to inform dash firmware driver is been brought up or
> brought down. So only call these two functions when dash is enabled.
> 
> Signed-off-by: Chun-Hao Lin <hau@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b5aab28..583ebca 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7388,9 +7388,10 @@ static void rtl_remove_one(struct pci_dev *pdev)
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
> +	     r8168_check_dash(tp)) {

Please fix the indentation on the final line of this if statement, it
needs 1 TAB and 4 SPACE characters.

> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
> +	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
> +	     r8168_check_dash(tp)) {

Likewise.
