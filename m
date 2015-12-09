From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] iwlegacy: mark il_adjust_beacon_interval as noinline
Date: Wed, 9 Dec 2015 12:13:14 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1512091209130.26920@knanqh.ubzr>
References: <36263581.L8412YxJjp@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <36263581.L8412YxJjp@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Dec 2015, Arnd Bergmann wrote:

> With the new optimized do_div() code, some versions of gcc
> produce obviously incorrect code that leads to a link error
> in iwlegacy/common.o:
> 
> drivers/built-in.o: In function `il_send_rxon_timing':
> :(.text+0xa6b4d4): undefined reference to `____ilog2_NaN'
> :(.text+0xa6b4f0): undefined reference to `__aeabi_uldivmod'
> 
> In a few thousand randconfig builds, I have seen this problem
> a couple of times in this file, but never anywhere else in the
> kernel, so we can try to work around this in the only file
> that shows the behavior, by marking the il_adjust_beacon_interval
> function as noinline, which convinces gcc to use the unoptimized
> do_div() all the time.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Nicolas Pitre <nico@linaro.org>

> 
> diff --git a/drivers/net/wireless/intel/iwlegacy/common.c b/drivers/net/wireless/intel/iwlegacy/common.c
> index 887114582583..6308bb217454 100644
> --- a/drivers/net/wireless/intel/iwlegacy/common.c
> +++ b/drivers/net/wireless/intel/iwlegacy/common.c
> @@ -3602,7 +3602,7 @@ il_is_ht40_tx_allowed(struct il_priv *il, struct ieee80211_sta_ht_cap *ht_cap)
>  }
>  EXPORT_SYMBOL(il_is_ht40_tx_allowed);
>  
> -static u16
> +static u16 noinline
>  il_adjust_beacon_interval(u16 beacon_val, u16 max_beacon_val)
>  {
>  	u16 new_val;
> 
> 
