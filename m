From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next v2 1/3] net: ethernet: mediatek: add extension of phy-mode for TRGMII
Date: Fri, 23 Sep 2016 11:32:51 +0800
Message-ID: <1474601571-9647-1-git-send-email-sean.wang@mediatek.com>
References: <9e375cf6-8283-b6fb-f21f-5d013c3172fa@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>
To: <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:12914 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754170AbcIWDc7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 23:32:59 -0400
In-Reply-To: <9e375cf6-8283-b6fb-f21f-5d013c3172fa@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Thu, 22 Sep 2016 14:30:53 +0300, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>>Hello.
>
>On 9/22/2016 5:33 AM, sean.wang@mediatek.com wrote:
>
>> From: Sean Wang <sean.wang@mediatek.com>
>>
>> adds PHY-mode "trgmii" as an extension for the operation mode of the 
>> PHY interface for PHY_INTERFACE_MODE_TRGMII.

.. deleted

>>  	switch (of_get_phy_mode(np)) {
>> +	case PHY_INTERFACE_MODE_TRGMII:
>> +		mac->trgmii = true;
>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>  	case PHY_INTERFACE_MODE_RGMII_RXID:
>>  	case PHY_INTERFACE_MODE_RGMII_ID:
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h 
>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> index 7c5e534..e3b9525 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> @@ -529,6 +529,8 @@ struct mtk_eth {
>>   * @hw:			Backpointer to our main datastruture
>>   * @hw_stats:		Packet statistics counter
>>   * @phy_dev:		The attached PHY if available
>> + * @trgmii		Indicate if the MAC uses TRGMII connected to internal
>> +			switch
>>   */
>>  struct mtk_mac {
>>  	int				id;
>> @@ -539,6 +541,7 @@ struct mtk_mac {
>>  	struct phy_device		*phy_dev;
>>  	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
>>  	int				hwlro_ip_cnt;
>> +	bool				trgmii;
>
>     I don't see where this is used.

I set trgmii as below
  	switch (of_get_phy_mode(np)) {
	case PHY_INTERFACE_MODE_TRGMII:
		mac->trgmii = true;
  	case PHY_INTERFACE_MODE_RGMII_TXID:

>[...]
>> diff --git a/include/linux/phy.h b/include/linux/phy.h index 
>> 2d24b28..e25f183 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -80,6 +80,7 @@ typedef enum {
>>  	PHY_INTERFACE_MODE_XGMII,
>>  	PHY_INTERFACE_MODE_MOCA,
>>  	PHY_INTERFACE_MODE_QSGMII,
>> +	PHY_INTERFACE_MODE_TRGMII,
>>  	PHY_INTERFACE_MODE_MAX,
>>  } phy_interface_t;
>>
>> @@ -123,6 +124,8 @@ static inline const char *phy_modes(phy_interface_t interface)
>>  		return "moca";
>>  	case PHY_INTERFACE_MODE_QSGMII:
>>  		return "qsgmii";
>> +	case PHY_INTERFACE_MODE_TRGMII:
>> +		return "trgmii";
>>  	default:
>>  		return "unknown";
>>  	}
>
>    I think this should be done in a separate phylib patch.

this patch is applied, so I am so little confused how to do this.
next time I will note placing modification for generic layer
into separate patch.

>
>MBR, Sergei
>
