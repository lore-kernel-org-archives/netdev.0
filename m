From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/7] r8169: Update PHY settings of RTL8111G
Date: Tue, 2 Apr 2013 00:20:48 +0200
Message-ID: <20130401222048.GA19335@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364824539-4156-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364824539-4156-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> - Replace the current settings with rtl_writephy and rtl_readphy.
>   For the hardware, the settings are same with previous ones. This
>   make the setting method like the previous chips.
> - Add new PHY settings.

Would you mind spliting it in two ?

On closer inspection the settings do not look the same.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 72 +++++++++++++++++++++++++-----------
>  1 file changed, 51 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index d36aa76..b8b59a9 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -3370,23 +3362,61 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
>  {
>  	rtl_apply_firmware(tp);
>  
> -	if (r8168_phy_ocp_read(tp, 0xa460) & 0x0100)
> -		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x8000);
> -	else
> -		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x8000, 0x0000);
> +	rtl_writephy(tp, 0x1f, 0x0a46);
> +	if (rtl_readphy(tp, 0x10) & 0x0100) {
> +		rtl_writephy(tp, 0x1f, 0x0bcc);
> +		rtl_w1w0_phy(tp, 0x12, 0x0000, 0x8000);
> +	} else {
> +		rtl_writephy(tp, 0x1f, 0x0bcc);
> +		rtl_w1w0_phy(tp, 0x12, 0x8000, 0x0000);
> +	}
>  
> -	if (r8168_phy_ocp_read(tp, 0xa466) & 0x0100)
> -		rtl_w1w0_phy_ocp(tp, 0xc41a, 0x0002, 0x0000);
> -	else
> -		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
                                     ^^^^^^
This one was not right, was it ?

> +	rtl_writephy(tp, 0x1f, 0x0a46);
> +	if (rtl_readphy(tp, 0x13) & 0x0100) {
> +		rtl_writephy(tp, 0x1f, 0x0c41);
> +		rtl_w1w0_phy(tp, 0x15, 0x0002, 0x0000);
> +	} else {
> +		rtl_writephy(tp, 0x1f, 0x0c41);
> +		rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0002);
> +	}

-- 
Ueimor
