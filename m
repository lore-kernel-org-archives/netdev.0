From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 6/11] rtlwifi: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 15:08:47 -0600
Message-ID: <52C1E0DF.2000800@lwfinger.net>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr> <1388427307-8691-7-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-7-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/30/2013 12:15 PM, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
>
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
> used when each argument is an array within a structure that contains at
> least two bytes of data beyond the array.
>
> The structures involved are:
> ieee80211_hdr defined in include/linux/ieee80211.h and
> rtl_mac defined in drivers/net/wireless/rtlwifi/wifi.h
>
> This was done using Coccinelle (http://coccinelle.lip6.fr/).
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry


>
> ---
> The semantic patch used is rather long and can be found in message 0 of
> this patch series.
>
>   drivers/net/wireless/rtlwifi/base.c |    4 ++--
>   drivers/net/wireless/rtlwifi/ps.c   |    4 ++--
>   2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
> index 0d81f76..deedae3 100644
> --- a/drivers/net/wireless/rtlwifi/ps.c
> +++ b/drivers/net/wireless/rtlwifi/ps.c
> @@ -478,7 +478,7 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
>   		return;
>
>   	/* and only beacons from the associated BSSID, please */
> -	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
> +	if (!ether_addr_equal_64bits(hdr->addr3, rtlpriv->mac80211.bssid))
>   		return;
>
>   	rtlpriv->psc.last_beacon = jiffies;
> @@ -923,7 +923,7 @@ void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len)
>   		return;
>
>   	/* and only beacons from the associated BSSID, please */
> -	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
> +	if (!ether_addr_equal_64bits(hdr->addr3, rtlpriv->mac80211.bssid))
>   		return;
>
>   	/* check if this really is a beacon */
> diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
> index fcf9b62..d63a12c 100644
> --- a/drivers/net/wireless/rtlwifi/base.c
> +++ b/drivers/net/wireless/rtlwifi/base.c
> @@ -1293,7 +1293,7 @@ void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb)
>   		return;
>
>   	/* and only beacons from the associated BSSID, please */
> -	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
> +	if (!ether_addr_equal_64bits(hdr->addr3, rtlpriv->mac80211.bssid))
>   		return;
>
>   	rtlpriv->link_info.bcn_rx_inperiod++;
> @@ -1781,7 +1781,7 @@ void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *data, unsigned int len)
>   		return;
>
>   	/* and only beacons from the associated BSSID, please */
> -	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
> +	if (!ether_addr_equal_64bits(hdr->addr3, rtlpriv->mac80211.bssid))
>   		return;
>
>   	if (rtl_find_221_ie(hw, data, len))
>
>
