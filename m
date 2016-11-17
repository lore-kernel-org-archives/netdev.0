From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [4.9.0-rc5] AR9300 calibration problems with antenna selected
Date: Thu, 17 Nov 2016 11:09:43 +0000 (UTC)
Message-ID: <20161117110943.D2D92615E1@smtp.codeaurora.org>
References: <m3wpg52hii.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Krzysztof =?utf-8?Q?Ha=C5=82asa?= <khalasa-NlWvg49iv0c@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m3wpg52hii.fsf-5rrSNkU2MPirDJvtcaxF/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Krzysztof wrote:
> Hi,
> 
> I recently tried to select a single antenna on AR9300 and it works for
> 30 seconds only. The subsequent calibration makes the RX signal level to
> drop from the usual -30/-40 dBm to -70/-80 dBm, and the transmission
> practically stops.
> 
> With the attached patch it works, though selecting the antenna doesn't
> seem to have any visible effect, at least with "iw wlanX station dump"
> (perhaps it works for TX).
> 
> I'm using ad-hoc mode:
> 
> rmmod ath9k
> modprobe ath9k
> iw dev wlan0 set type ibss
> iw phy phyX set antenna 2
> ip link set up dev wlan0
> iw dev wlan0 set bitrates legacy-2.4 18
> iw dev wlan0 ibss join nameXXX freqYYY
> ip addr add ZZZ broadcast + dev wlan0
> 
> The card in question is Mikrotik (Routerboard) R11e-2HPnD mPCIe adapter:
> AR9580 Wireless Network Adapter (rev 01), ID 168c:0033, subsystem
> 19b6:d016.
> ieee80211 phy0: Atheros AR9300 Rev:4 mem=0xc0f40000, irq=334
> https://routerboard.com/R11e-2HPnD
> 
> Linux 4.9.0-rc5.
> 
> 
> Is there a better way?
> 
> Signed-off-by: Krzysztof Halasa <khalasa-NlWvg49iv0c@public.gmane.org>
> 
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
> index e9f32b5..7f17e5d 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -2245,7 +2245,7 @@ static int ath9k_set_antenna(struct ieee80211_hw *hw, u32 tx_ant, u32 rx_ant)
>  		return 0;
>  
>  	/* AR9100 runs into calibration issues if not all rx chains are enabled */
> -	if (AR_SREV_9100(ah))
> +	if (AR_SREV_9100(ah) || AR_SREV_9300(ah))
>  		ah->rxchainmask = 0x7;
>  	else
>  		ah->rxchainmask = fill_chainmask(ah->caps.rx_chainmask, rx_ant);

I'll assume this is an RFC patch. Please resubmit if this is the right
approach.

Patch set to RFC.

-- 
https://patchwork.kernel.org/patch/9429263/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
