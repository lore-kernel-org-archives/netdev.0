From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 linux-next] ath5k: use swap() in
 ath5k_hw_get_median_noise_floor()
Date: Wed, 10 Jun 2015 12:52:46 -0700
Message-ID: <1433965966.32331.25.camel@perches.com>
References: <1433954015-24872-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433954015-24872-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-10 at 18:33 +0200, Fabian Frederick wrote:
> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
[]
> diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
[]
> @@ -1566,17 +1566,13 @@ static s16
>  ath5k_hw_get_median_noise_floor(struct ath5k_hw *ah)
>  {
>  	s16 sort[ATH5K_NF_CAL_HIST_MAX];
> -	s16 tmp;
>  	int i, j;
>  
>  	memcpy(sort, ah->ah_nfcal_hist.nfval, sizeof(sort));
>  	for (i = 0; i < ATH5K_NF_CAL_HIST_MAX - 1; i++) {
>  		for (j = 1; j < ATH5K_NF_CAL_HIST_MAX - i; j++) {
> -			if (sort[j] > sort[j - 1]) {
> -				tmp = sort[j];
> -				sort[j] = sort[j - 1];
> -				sort[j - 1] = tmp;
> -			}
> +			if (sort[j] > sort[j - 1])
> +				swap(sort[j], sort[j]);

swap(a, a) doesn't look useful.
