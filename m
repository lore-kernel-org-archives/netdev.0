From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH net-next] wireless: Use bool function returns of true/false
 instead of 1/0
Date: Sun, 29 Mar 2015 20:46:37 -0500
Message-ID: <5518AAFD.1050202@lwfinger.net>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>	 <20150325215525.GA26868@athens>	 <20150329.121655.2092434262655191613.davem@davemloft.net>	 <1427678712.2715.52.camel@perches.com> <1427678982.2715.55.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	Kalle Valo <kvalo@codeaurora.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list <brcm80211-dev-list@broadcom.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427678982.2715.55.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/29/2015 08:29 PM, Joe Perches wrote:
> Use bool constants as the return values instead of 1 and 0.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>> To be honest I'd might rather get bunches of these, there has to be a ton
>> of them, than a slow trickle of one every few weeks/days.
>
> There aren't too many here either...
>
>   drivers/net/wireless/b43/dma.c                        | 12 ++++++------
>   drivers/net/wireless/b43legacy/dma.c                  |  6 +++---
>   drivers/net/wireless/b43legacy/rfkill.c               |  8 ++++----
>   drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c |  2 +-
>   drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c |  2 +-
>   drivers/net/wireless/iwlwifi/iwl-config.h             |  4 ++--
>   6 files changed, 17 insertions(+), 17 deletions(-)

Please split these into separate patches for each driver. That way it will be 
possible to search 'git log' for the contributions to each driver. Otherwise, 
the patches are OK.

Thanks,

Larry

>
> diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
> index 1d7982a..6837064 100644
> --- a/drivers/net/wireless/b43/dma.c
> +++ b/drivers/net/wireless/b43/dma.c
> @@ -553,7 +553,7 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
>   				  size_t buffersize, bool dma_to_device)
>   {
>   	if (unlikely(dma_mapping_error(ring->dev->dev->dma_dev, addr)))
> -		return 1;
> +		return true;
>
>   	switch (ring->type) {
>   	case B43_DMA_30BIT:
> @@ -571,13 +571,13 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
>   	}
>
>   	/* The address is OK. */
> -	return 0;
> +	return false;
>
>   address_error:
>   	/* We can't support this address. Unmap it again. */
>   	unmap_descbuffer(ring, addr, buffersize, dma_to_device);
>
> -	return 1;
> +	return true;
>   }
>
>   static bool b43_rx_buffer_is_poisoned(struct b43_dmaring *ring, struct sk_buff *skb)
> @@ -1099,16 +1099,16 @@ static bool b43_dma_translation_in_low_word(struct b43_wldev *dev,
>   					    enum b43_dmatype type)
>   {
>   	if (type != B43_DMA_64BIT)
> -		return 1;
> +		return true;
>
>   #ifdef CONFIG_B43_SSB
>   	if (dev->dev->bus_type == B43_BUS_SSB &&
>   	    dev->dev->sdev->bus->bustype == SSB_BUSTYPE_PCI &&
>   	    !(pci_is_pcie(dev->dev->sdev->bus->host_pci) &&
>   	      ssb_read32(dev->dev->sdev, SSB_TMSHIGH) & SSB_TMSHIGH_DMA64))
> -			return 1;
> +			return true;
>   #endif
> -	return 0;
> +	return false;
>   }
>
>   int b43_dma_init(struct b43_wldev *dev)
> diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
> index b2ed179..f9dd892 100644
> --- a/drivers/net/wireless/b43legacy/dma.c
> +++ b/drivers/net/wireless/b43legacy/dma.c
> @@ -427,7 +427,7 @@ static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
>   					 bool dma_to_device)
>   {
>   	if (unlikely(dma_mapping_error(ring->dev->dev->dma_dev, addr)))
> -		return 1;
> +		return true;
>
>   	switch (ring->type) {
>   	case B43legacy_DMA_30BIT:
> @@ -441,13 +441,13 @@ static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
>   	}
>
>   	/* The address is OK. */
> -	return 0;
> +	return false;
>
>   address_error:
>   	/* We can't support this address. Unmap it again. */
>   	unmap_descbuffer(ring, addr, buffersize, dma_to_device);
>
> -	return 1;
> +	return true;
>   }
>
>   static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
> diff --git a/drivers/net/wireless/b43legacy/rfkill.c b/drivers/net/wireless/b43legacy/rfkill.c
> index c4559bc..7c1bdbc 100644
> --- a/drivers/net/wireless/b43legacy/rfkill.c
> +++ b/drivers/net/wireless/b43legacy/rfkill.c
> @@ -32,7 +32,7 @@ bool b43legacy_is_hw_radio_enabled(struct b43legacy_wldev *dev)
>   	if (dev->dev->id.revision >= 3) {
>   		if (!(b43legacy_read32(dev, B43legacy_MMIO_RADIO_HWENABLED_HI)
>   		      & B43legacy_MMIO_RADIO_HWENABLED_HI_MASK))
> -			return 1;
> +			return true;
>   	} else {
>   		/* To prevent CPU fault on PPC, do not read a register
>   		 * unless the interface is started; however, on resume
> @@ -40,12 +40,12 @@ bool b43legacy_is_hw_radio_enabled(struct b43legacy_wldev *dev)
>   		 * that happens, unconditionally return TRUE.
>   		 */
>   		if (b43legacy_status(dev) < B43legacy_STAT_STARTED)
> -			return 1;
> +			return true;
>   		if (b43legacy_read16(dev, B43legacy_MMIO_RADIO_HWENABLED_LO)
>   		    & B43legacy_MMIO_RADIO_HWENABLED_LO_MASK)
> -			return 1;
> +			return true;
>   	}
> -	return 0;
> +	return false;
>   }
>
>   /* The poll callback for the hardware button. */
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
> index 941b1e4..1c4e9dd 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
> @@ -2949,5 +2949,5 @@ bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *ppi)
>   	if (ISNPHY(pi))
>   		return wlc_phy_n_txpower_ipa_ison(pi);
>   	else
> -		return 0;
> +		return false;
>   }
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
> index 5f13662..93d4cde 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
> @@ -4999,7 +4999,7 @@ void wlc_2064_vco_cal(struct brcms_phy *pi)
>   bool wlc_phy_tpc_isenabled_lcnphy(struct brcms_phy *pi)
>   {
>   	if (wlc_lcnphy_tempsense_based_pwr_ctrl_enabled(pi))
> -		return 0;
> +		return false;
>   	else
>   		return (LCNPHY_TX_PWR_CTRL_HW ==
>   			wlc_lcnphy_get_tx_pwr_ctrl((pi)));
> diff --git a/drivers/net/wireless/iwlwifi/iwl-config.h b/drivers/net/wireless/iwlwifi/iwl-config.h
> index 4b190d9..19f3be0 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-config.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-config.h
> @@ -92,9 +92,9 @@ static inline bool iwl_has_secure_boot(u32 hw_rev,
>   {
>   	/* return 1 only for family 8000 B0 */
>   	if ((family == IWL_DEVICE_FAMILY_8000) && (hw_rev & 0xC))
> -		return 1;
> +		return true;
>
> -	return 0;
> +	return false;
>   }
>
>   /*
>
>
>
