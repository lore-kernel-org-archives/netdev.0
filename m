From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 1/2] ath: Fix ath_dbg uses missing newlines and access
 beyond array bound
Date: Thu, 2 Dec 2010 11:02:39 -0800
Message-ID: <20101202190239.GE7399@tux>
References: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	Jouni Malinen <Jouni.Malinen@Atheros.com>,
	Vasanth Thiagarajan <Vasanth.Thiagarajan@Atheros.com>,
	Senthilkumar Balasubramanian
	<Senthilkumar.Balasubramanian@Atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2010 at 09:13:32PM -0800, Joe Perches wrote:
> Add missing newlines to ath_dbg uses
> ar9300RateSize is not a power of 4, fix to print array line by line.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   29 ++---------------------
>  drivers/net/wireless/ath/ath9k/calib.c         |    4 +-
>  drivers/net/wireless/ath/ath9k/gpio.c          |    6 ++--
>  drivers/net/wireless/ath/ath9k/htc_drv_gpio.c  |    7 ++---
>  drivers/net/wireless/ath/ath9k/htc_drv_main.c  |    2 +-
>  5 files changed, 12 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
> index e6ae62b..beb3e87 100644
> --- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
> +++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
> @@ -3342,7 +3342,7 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
>  	goto fail;
>  
>  found:
> -	ath_dbg(common, ATH_DBG_EEPROM, "Found valid EEPROM data");
> +	ath_dbg(common, ATH_DBG_EEPROM, "Found valid EEPROM data\n");
>  
>  	for (it = 0; it < MSTATE; it++) {
>  		if (!read(ah, cptr, word, COMP_HDR_LEN))
> @@ -4084,22 +4084,9 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
>  	    ar9003_hw_eeprom_get_ht40_tgt_pwr(ah, HT_TARGET_RATE_23, freq,
>  					      is2GHz) + ht40PowerIncForPdadc;
>  
> -	while (i < ar9300RateSize) {
> -		ath_dbg(common, ATH_DBG_EEPROM,
> -			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
> -		i++;
> -
> -		ath_dbg(common, ATH_DBG_EEPROM,
> -			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
> -		i++;
> -
> -		ath_dbg(common, ATH_DBG_EEPROM,
> -			"TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
> -		i++;
> -
> +	for (i = 0; i < ar9300RateSize; i++) {
>  		ath_dbg(common, ATH_DBG_EEPROM,
>  			"TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
> -		i++;
>  	}
>  }

Please send this hunk on a separate patch.

  Luis
 
