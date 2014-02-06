From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/2] rtlwifi: Fix incorrect return from rtl_ps_enable_nic()
Date: Thu, 06 Feb 2014 14:39:30 -0600
Message-ID: <52F3F302.1040703@lwfinger.net>
References: <1391235070-23180-1-git-send-email-olivier@trillion01.com> <1391235070-23180-2-git-send-email-olivier@trillion01.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Olivier Langlois <olivier@trillion01.com>, linville@tuxdriver.com,
	chaoming_li@realsil.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391235070-23180-2-git-send-email-olivier@trillion01.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2014 12:11 AM, Olivier Langlois wrote:
> rtl_ps_enable_nic() is called from loops that will loop until this function returns true or a
> maximum number of retries is performed.
>
> hw_init() returns non-zero on error. In that situation return false to
> restore the original design intent to retry hw init when it fails.
>
> Signed-off-by: Olivier Langlois <olivier@trillion01.com>
> Cc: Stable <stable@vger.kernel.org>

Acked-by: Larry Finger <Larry.Finger.net>

Larry

> ---
>   drivers/net/wireless/rtlwifi/ps.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
> index 0d81f76..a56e9b3 100644
> --- a/drivers/net/wireless/rtlwifi/ps.c
> +++ b/drivers/net/wireless/rtlwifi/ps.c
> @@ -48,7 +48,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
>
>   	/*<2> Enable Adapter */
>   	if (rtlpriv->cfg->ops->hw_init(hw))
> -		return 1;
> +		return false;
>   	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
>
>   	/*<3> Enable Interrupt */
>
