From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: Re: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Tue, 28 Oct 2014 23:43:44 -0200
Message-ID: <54504650.6060905@gmail.com>
References: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	netdev@vger.kernel.org, Mike Galbraith <umgwanakikbuti@gmail.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>
To: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:54785 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbaJ2Bp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 21:45:26 -0400
In-Reply-To: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 02:27 PM, Larry Finger wrote:
> Drivers that do not use the get_btc_status() callback may not define a
> dummy routine. The caller needs to check before making the call.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
> Cc: Mike Galbraith <umgwanakikbuti@gmail.com>
> Cc: Thadeu Cascardo <cascardo@cascardo.eti.br>
> ---
>
> John,
>
> This missing statement is causing kernel crashes for several of the drivers.
> This patch should be applied ASAP.
>
> Larry
> ---
>
>   drivers/net/wireless/rtlwifi/pci.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
> index 667aba8..25daa87 100644
> --- a/drivers/net/wireless/rtlwifi/pci.c
> +++ b/drivers/net/wireless/rtlwifi/pci.c
> @@ -1796,7 +1796,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
>   	rtl_pci_reset_trx_ring(hw);
>
>   	rtlpci->driver_is_goingto_unload = false;
> -	if (rtlpriv->cfg->ops->get_btc_status()) {
> +	if (rtlpriv->cfg->ops->get_btc_status &&
> +	    rtlpriv->cfg->ops->get_btc_status()) {
>   		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
>   		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
>   	}
>
Hi, Larry & everyone.

This patch didn't solve and next-20141028 is still crashing on my laptop 
with rtl8192se device:

http://opsfelder.com/~murilo/lkml/next-20141028_crashing.jpg

-- 
Murilo
