From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: pull request: wireless 2012-03-30
Date: Fri, 30 Mar 2012 20:06:24 +0200
Message-ID: <4F75F620.9030101@hartkopp.net>
References: <20120330175533.GC8273@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:45000 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab2C3SG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 14:06:28 -0400
In-Reply-To: <20120330175533.GC8273@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello John,

there are at least two patches that i know from that fix issues in the current
3.4-merge tree.

[PATCH] iwlwifi: fix unused variable warning
http://marc.info/?l=linux-wireless&m=133266148006409&w=2
Acked-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
http://marc.info/?l=linux-wireless&m=133272671523532&w=2

[PATCH 3.4] mac80211: fix association beacon wait timeout
http://marc.info/?l=linux-wireless&m=133296144416566&w=2
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
http://marc.info/?l=linux-wireless&m=133296423617914&w=2

Did you miss them?

Regards,
Oliver

On 30.03.2012 19:55, John W. Linville wrote:

> commit de312db345f9770b64ff39ef5a7f86f6358e93cc
> 
> Dave,
> 
> I have a few more small fixes, hopefully still in time for 3.4-rc1...
> 
> Rajkukmar provides us with a one-line timestamp correction related to
> scanning in mac80211.  Sujith gives us a small fixup for a regression
> in the handling of HT capability bits for ath9k.  Stanislav Yakovlev
> is stepping-up as maintainer for the ipw2x00 drivers, so we'll add
> him to MAINTAINERS.  Stanislav also gives us a fix for a thinko
> that registers the wrong band information for ipw2200 and 802.11a.
> Finally, Santosh Nayak adds some simple error checking to orinoco to
> avoid some potential NULL pointer dereferences.
> 
> Please let me know if there are problems!
> 
> Thanks,
> 
> John
> 
> ---
> 
> The following changes since commit 643c61e119459e9d750087b7b34be94491efebf9:
> 
>   rtlwifi: rtl8192ce: rtl8192cu: rtl8192de: Fix low-gain setting when scanning (2012-03-26 15:07:30 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master
> 
> Rajkumar Manoharan (1):
>       mac80211: fix oper channel timestamp updation
> 
> Santosh Nayak (1):
>       net: orinoco: add error handling for failed kmalloc().
> 
> Stanislav Yakovlev (2):
>       net/wireless: ipw2x00: fix a typo in wiphy struct initilization
>       MAINTAINERS: adding maintainer for ipw2x00
> 
> Sujith Manoharan (1):
>       ath9k: Use HW HT capabilites properly
> 
>  MAINTAINERS                            |   12 ++++--------
>  drivers/net/wireless/ath/ath9k/main.c  |    4 ++--
>  drivers/net/wireless/ipw2x00/ipw2200.c |    4 ++--
>  drivers/net/wireless/orinoco/main.c    |    8 ++++++++
>  net/mac80211/scan.c                    |    2 +-
>  5 files changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 0ddc77fe..09a79f9 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3519,17 +3519,13 @@ L:	linux-pm@vger.kernel.org
>  S:	Supported
>  F:	arch/x86/platform/mrst/pmu.*
>  
> -INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
> +INTEL PRO/WIRELESS 2100, 2200BG, 2915ABG NETWORK CONNECTION SUPPORT
> +M:	Stanislav Yakovlev <stas.yakovlev@gmail.com>
>  L:	linux-wireless@vger.kernel.org
> -S:	Orphan
> +S:	Maintained
>  F:	Documentation/networking/README.ipw2100
> -F:	drivers/net/wireless/ipw2x00/ipw2100.*
> -
> -INTEL PRO/WIRELESS 2915ABG NETWORK CONNECTION SUPPORT
> -L:	linux-wireless@vger.kernel.org
> -S:	Orphan
>  F:	Documentation/networking/README.ipw2200
> -F:	drivers/net/wireless/ipw2x00/ipw2200.*
> +F:	drivers/net/wireless/ipw2x00/
>  
>  INTEL(R) TRUSTED EXECUTION TECHNOLOGY (TXT)
>  M:	Joseph Cihula <joseph.cihula@intel.com>
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
> index 3879485..215eb25 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -640,7 +640,7 @@ static void ath_node_attach(struct ath_softc *sc, struct ieee80211_sta *sta,
>  	an->sta = sta;
>  	an->vif = vif;
>  
> -	if (sta->ht_cap.ht_supported) {
> +	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT) {
>  		ath_tx_node_init(sc, an);
>  		an->maxampdu = 1 << (IEEE80211_HT_MAX_AMPDU_FACTOR +
>  				     sta->ht_cap.ampdu_factor);
> @@ -659,7 +659,7 @@ static void ath_node_detach(struct ath_softc *sc, struct ieee80211_sta *sta)
>  	an->sta = NULL;
>  #endif
>  
> -	if (sta->ht_cap.ht_supported)
> +	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT)
>  		ath_tx_node_cleanup(sc, an);
>  }
>  
> diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
> index 4fcdac6..2b02257 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2200.c
> @@ -11507,9 +11507,9 @@ static int ipw_wdev_init(struct net_device *dev)
>  			rc = -ENOMEM;
>  			goto out;
>  		}
> -		/* translate geo->bg to a_band.channels */
> +		/* translate geo->a to a_band.channels */
>  		for (i = 0; i < geo->a_channels; i++) {
> -			a_band->channels[i].band = IEEE80211_BAND_2GHZ;
> +			a_band->channels[i].band = IEEE80211_BAND_5GHZ;
>  			a_band->channels[i].center_freq = geo->a[i].freq;
>  			a_band->channels[i].hw_value = geo->a[i].channel;
>  			a_band->channels[i].max_power = geo->a[i].max_power;
> diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
> index dd6c64a..88e3ad2 100644
> --- a/drivers/net/wireless/orinoco/main.c
> +++ b/drivers/net/wireless/orinoco/main.c
> @@ -1336,6 +1336,10 @@ static void qbuf_scan(struct orinoco_private *priv, void *buf,
>  	unsigned long flags;
>  
>  	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
> +	if (!sd) {
> +		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
> +		return;
> +	}
>  	sd->buf = buf;
>  	sd->len = len;
>  	sd->type = type;
> @@ -1353,6 +1357,10 @@ static void qabort_scan(struct orinoco_private *priv)
>  	unsigned long flags;
>  
>  	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
> +	if (!sd) {
> +		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
> +		return;
> +	}
>  	sd->len = -1; /* Abort */
>  
>  	spin_lock_irqsave(&priv->scan_lock, flags);
> diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
> index 33cd169..c70e176 100644
> --- a/net/mac80211/scan.c
> +++ b/net/mac80211/scan.c
> @@ -370,7 +370,7 @@ static int ieee80211_start_sw_scan(struct ieee80211_local *local)
>  	 */
>  	drv_sw_scan_start(local);
>  
> -	local->leave_oper_channel_time = 0;
> +	local->leave_oper_channel_time = jiffies;
>  	local->next_scan_state = SCAN_DECISION;
>  	local->scan_channel_idx = 0;
>  
