From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] rtl8xxxu: fix typo on variable name, compare against correct variable
Date: Fri, 03 Jun 2016 15:31:03 -0400
Message-ID: <wrfjoa7iysqw.fsf@redhat.com>
References: <1464798225-7315-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbcFCTbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 15:31:04 -0400
In-Reply-To: <1464798225-7315-1-git-send-email-colin.king@canonical.com>
	(Colin King's message of "Wed, 1 Jun 2016 17:23:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin King <colin.king@canonical.com> writes:
> From: Colin Ian King <colin.king@canonical.com>
>
> path_b_ok is being assigned but immediately after path_a_ok is being
> compared to the value 0x03.  This appears to be a typo on the
> variable name, compare path_b_ok instead.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> index fe19ace..b04cf30 100644
> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> @@ -1149,7 +1149,7 @@ static void rtl8192eu_phy_iqcalibrate(struct rtl8xxxu_priv *priv,
>  
>  		for (i = 0; i < retry; i++) {
>  			path_b_ok = rtl8192eu_rx_iqk_path_b(priv);
> -			if (path_a_ok == 0x03) {
> +			if (path_b_ok == 0x03) {
>  				val32 = rtl8xxxu_read32(priv,
>  							REG_RX_POWER_BEFORE_IQK_B_2);
>  				result[t][6] = (val32 >> 16) & 0x3ff;

Nice catch, that does indeed look like a bug!

Thanks, I want to test it, but I plan to apply it to rtl8xxxu-devel
shortly.

Cheers,
Jes
