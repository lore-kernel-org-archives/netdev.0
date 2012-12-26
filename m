From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3.8 5/5] rtlwifi: rtl8723ae: Fix warning for unchecked
 pci_map_single() call
Date: Wed, 26 Dec 2012 15:13:51 -0800
Message-ID: <1356563631.30414.3.camel@edumazet-glaptop>
References: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1356559691-5048-6-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42071 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab2LZXNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:13:54 -0500
In-Reply-To: <1356559691-5048-6-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-26 at 16:08 -0600, Larry Finger wrote:
> Kernel 3.8 implements checking of all DMA mapping calls and issues
> a WARNING for the first it finds that is not checked.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
> index 87331d8..7ddd517 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
> @@ -387,6 +387,12 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
>  					    PCI_DMA_TODEVICE);
>  	u8 bw_40 = 0;
>  
> +	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
> +		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
> +			 "DMA mapping error");
> +		return;
> +	}
> +	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
>  	if (mac->opmode == NL80211_IFTYPE_STATION) {
>  		bw_40 = mac->bw_40;
>  	} else if (mac->opmode == NL80211_IFTYPE_AP ||
> @@ -542,6 +548,12 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
>  					    PCI_DMA_TODEVICE);
>  	__le16 fc = hdr->frame_control;
>  
> +	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
> +		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
> +			 "DMA mapping error");
> +		return;
> +	}
> +	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
>  	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
>  
>  	if (firstseg)

This seems wrong... 

CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE) doesnt need to be done
twice, does it ?
