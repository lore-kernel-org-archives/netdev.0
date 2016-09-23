From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Fri, 23 Sep 2016 13:19:51 +0300
Message-ID: <b8791155-c1c0-6dc8-13d1-7940cc34f689@cogentembedded.com>
References: <9e375cf6-8283-b6fb-f21f-5d013c3172fa@cogentembedded.com>
 <1474601571-9647-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35615 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752747AbcIWKT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 06:19:56 -0400
Received: by mail-lf0-f46.google.com with SMTP id l131so89224673lfl.2
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 03:19:55 -0700 (PDT)
In-Reply-To: <1474601571-9647-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/23/2016 6:32 AM, Sean Wang wrote:

>>> From: Sean Wang <sean.wang@mediatek.com>
>>>
>>> adds PHY-mode "trgmii" as an extension for the operation mode of the
>>> PHY interface for PHY_INTERFACE_MODE_TRGMII.
>
> .. deleted

    What? Why?

>>>  	switch (of_get_phy_mode(np)) {
>>> +	case PHY_INTERFACE_MODE_TRGMII:
>>> +		mac->trgmii = true;
>>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>>  	case PHY_INTERFACE_MODE_RGMII_RXID:
>>>  	case PHY_INTERFACE_MODE_RGMII_ID:
>>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>>> index 7c5e534..e3b9525 100644
>>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>>> @@ -529,6 +529,8 @@ struct mtk_eth {
>>>   * @hw:			Backpointer to our main datastruture
>>>   * @hw_stats:		Packet statistics counter
>>>   * @phy_dev:		The attached PHY if available
>>> + * @trgmii		Indicate if the MAC uses TRGMII connected to internal
>>> +			switch
>>>   */
>>>  struct mtk_mac {
>>>  	int				id;
>>> @@ -539,6 +541,7 @@ struct mtk_mac {
>>>  	struct phy_device		*phy_dev;
>>>  	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
>>>  	int				hwlro_ip_cnt;
>>> +	bool				trgmii;
>>
>>     I don't see where this is used.
>
> I set trgmii as below
>   	switch (of_get_phy_mode(np)) {
> 	case PHY_INTERFACE_MODE_TRGMII:
> 		mac->trgmii = true;
>   	case PHY_INTERFACE_MODE_RGMII_TXID:

    You only set it in this patch but don't check it, so this is essentially a 
NOP. It only gets checked in another patch...

>> [...]
>>> diff --git a/include/linux/phy.h b/include/linux/phy.h index
>>> 2d24b28..e25f183 100644
>>> --- a/include/linux/phy.h
>>> +++ b/include/linux/phy.h
>>> @@ -80,6 +80,7 @@ typedef enum {
>>>  	PHY_INTERFACE_MODE_XGMII,
>>>  	PHY_INTERFACE_MODE_MOCA,
>>>  	PHY_INTERFACE_MODE_QSGMII,
>>> +	PHY_INTERFACE_MODE_TRGMII,
>>>  	PHY_INTERFACE_MODE_MAX,
>>>  } phy_interface_t;
>>>
>>> @@ -123,6 +124,8 @@ static inline const char *phy_modes(phy_interface_t interface)
>>>  		return "moca";
>>>  	case PHY_INTERFACE_MODE_QSGMII:
>>>  		return "qsgmii";
>>> +	case PHY_INTERFACE_MODE_TRGMII:
>>> +		return "trgmii";
>>>  	default:
>>>  		return "unknown";
>>>  	}
>>
>>    I think this should be done in a separate phylib patch.
>
> this patch is applied, so I am so little confused how to do this.

    Right, it's too late now.

MBR, Sergei
