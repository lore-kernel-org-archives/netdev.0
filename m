From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath9k: Add cast to u8 to FREQ2FBIN macro
Date: Thu, 06 Apr 2017 14:29:20 -0700
Message-ID: <1491514160.27353.102.camel@perches.com>
References: <20170406212135.72157-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170406212135.72157-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-06 at 14:21 -0700, Matthias Kaehlcke wrote:
> The macro results are assigned to u8 variables/fields. Adding the cast
> fixes plenty of clang warnings about "implicit conversion from 'int' to
> 'u8'".
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  drivers/net/wireless/ath/ath9k/eeprom.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
> index 30bf722e33ed..31390af6c33e 100644
> --- a/drivers/net/wireless/ath/ath9k/eeprom.h
> +++ b/drivers/net/wireless/ath/ath9k/eeprom.h
> @@ -106,7 +106,7 @@
>  #define AR9285_RDEXT_DEFAULT    0x1F
>  
>  #define ATH9K_POW_SM(_r, _s)	(((_r) & 0x3f) << (_s))
> -#define FREQ2FBIN(x, y)		((y) ? ((x) - 2300) : (((x) - 4800) / 5))
> +#define FREQ2FBIN(x, y)		(u8)((y) ? ((x) - 2300) : (((x) - 4800) / 5))

Maybe better to use:

static inline u8 FREQ2FBIN(int x, int y)
{
	if (y)
		return x - 2300;
	return (x - 4800) / 5;
}
