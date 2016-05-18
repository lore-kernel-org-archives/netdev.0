From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1] rtlwifi: rtl8192ee: simplify coding
Date: Wed, 18 May 2016 07:02:49 -0500
Message-ID: <573C59E9.8090902@lwfinger.net>
References: <1463532238-13135-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36447 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbcERMC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 08:02:57 -0400
In-Reply-To: <1463532238-13135-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2016 07:43 PM, Heinrich Schuchardt wrote:
> Simplify _rtl92ee_phy_path_adda_on.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>   drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c | 13 ++-----------
>   1 file changed, 2 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
> index 018340a..c2bf8d1 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
> @@ -2414,19 +2414,10 @@ static void _rtl92ee_phy_reload_mac_registers(struct ieee80211_hw *hw,
>   static void _rtl92ee_phy_path_adda_on(struct ieee80211_hw *hw, u32 *addareg,
>   				      bool is_patha_on, bool is2t)
>   {
> -	u32 pathon;
>   	u32 i;
>
> -	pathon = is_patha_on ? 0x0fc01616 : 0x0fc01616;
> -	if (!is2t) {
> -		pathon = 0x0fc01616;
> -		rtl_set_bbreg(hw, addareg[0], MASKDWORD, 0x0fc01616);
> -	} else {
> -		rtl_set_bbreg(hw, addareg[0], MASKDWORD, pathon);
> -	}
> -
> -	for (i = 1; i < IQK_ADDA_REG_NUM; i++)
> -		rtl_set_bbreg(hw, addareg[i], MASKDWORD, pathon);
> +	for (i = 0; i < IQK_ADDA_REG_NUM; i++)
> +		rtl_set_bbreg(hw, addareg[i], MASKDWORD, 0x0fc01616);
>   }
>
>   static void _rtl92ee_phy_mac_setting_calibration(struct ieee80211_hw *hw,

Initially the thought was that addareg[0] would need to be set differently for 
devices with 2 TX paths. For that reason, this routine was coded as shown. As 
that assumption is no longer valid, this change should be made.

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
