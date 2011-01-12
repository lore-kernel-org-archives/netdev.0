From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] [RFC] ath9k: Fix reporting of RX STBC
 streams to userspace
Date: Tue, 11 Jan 2011 18:19:46 -0700
Message-ID: <4D2D01B2.1050201@openwrt.org>
References: <1294765194-30542-1-git-send-email-walle@corscience.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, jmalinen@atheros.com,
	senthilkumar@atheros.com, ath9k-devel@lists.ath9k.org,
	vasanth@atheros.com, linux-kernel@vger.kernel.org
To: Bernhard Walle <walle@corscience.de>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1294765194-30542-1-git-send-email-walle@corscience.de>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

On 2011-01-11 9:59 AM, Bernhard Walle wrote:
> While the driver reports
>
>          ath: TX streams 2, RX streams: 2
>
> in the kernel log (with ATH_DBG_CONFIG set in the debug module
> parameter), "iw list" only reported
>
> [...]
>          Capabilities: 0x12ce
>                  HT20/HT40
>                  SM Power Save disabled
>                  RX HT40 SGI
>                  TX STBC
>                  RX STBC 1-streams
> [...]
>
> The driver seems to set the value as flag while the iw tool interprets
> it as number. This patch fixes that.
>
> Signed-off-by: Bernhard Walle<walle@corscience.de>
> ---
>   drivers/net/wireless/ath/ath9k/init.c |   12 ++++++------
>   1 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
> index 639dc93..935b6c3 100644
> --- a/drivers/net/wireless/ath/ath9k/init.c
> +++ b/drivers/net/wireless/ath/ath9k/init.c
> @@ -215,17 +215,17 @@ static void setup_ht_cap(struct ath_softc *sc,
>   	else
>   		max_streams = 2;
>
> -	if (AR_SREV_9280_20_OR_LATER(ah)) {
> -		if (max_streams>= 2)
> -			ht_info->cap |= IEEE80211_HT_CAP_TX_STBC;
> -		ht_info->cap |= (1<<  IEEE80211_HT_CAP_RX_STBC_SHIFT);
> -	}
> -
>   	/* set up supported mcs set */
>   	memset(&ht_info->mcs, 0, sizeof(ht_info->mcs));
>   	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, max_streams);
>   	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, max_streams);
>
> +	if (AR_SREV_9280_20_OR_LATER(ah)) {
> +		if (max_streams>= 2)
> +			ht_info->cap |= IEEE80211_HT_CAP_TX_STBC;
> +		ht_info->cap |= (rx_streams<<  IEEE80211_HT_CAP_RX_STBC_SHIFT);
> +	}
> +
Are you sure the card can actually receive multiple streams via STBC? As 
far as I know, only one stream can be received properly via STBC, more 
streams have to be sent without it.

- Felix
