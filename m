From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 02/18] stmmac: rework DMA bus setting and
 introduce new platform AXI structure
Date: Tue, 5 Jan 2016 10:32:08 +0100
Message-ID: <568B8D98.2020102@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>	<1451912823-5245-3-git-send-email-peppe.cavallaro@st.com> <20160104.222955.94740482244105696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:64107 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbcAEJcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 04:32:14 -0500
In-Reply-To: <20160104.222955.94740482244105696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/2016 4:29 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Mon, 4 Jan 2016 14:06:47 +0100
>
>> @@ -81,7 +81,7 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
>>   	plat->mdio_bus_data->phy_mask = 0;
>>
>>   	plat->dma_cfg->pbl = 32;
>> -	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
>> +	/* TODO: AXI */
>>
>>   	/* Set default value for multicast hash bins */
>>   	plat->multicast_filter_bins = HASH_TABLE_SIZE;
>> @@ -115,8 +115,8 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>>   	plat->mdio_bus_data->phy_mask = 0;
>>
>>   	plat->dma_cfg->pbl = 16;
>> -	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
>>   	plat->dma_cfg->fixed_burst = 1;
>> +	/* AXI (TODO) */
>>
>>   	/* Set default value for multicast hash bins */
>>   	plat->multicast_filter_bins = HASH_TABLE_SIZE;
>
> Isn't this going to cause a regression for some things?

trying to rebuild the story of this setting, I understand it
was added to align a configuration so not for fixing some
known problem. I do not see any issue on my side indeed with
the patch applied. My understanding is that, when we adopt "fixed burst
length" it is more safe to use the default burst length instead of
tuning it to the maximum value. I met the same on platform driver
where for performance issue and just in some cases it helped to play
with AXI parameters.

For sure, if somebody has different behavior I can shortly arrange the
code to keep the previous setting or complete the AXI management for PCI
driver (providing a default setup).

Let me know what do you think.

peppe
