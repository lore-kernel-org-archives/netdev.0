From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: fix dma operation mode config for older
 versions
Date: Wed, 22 Mar 2017 11:07:08 +0000
Message-ID: <0d1ff4c8-a438-f746-ef7e-9f8eb39ba352@synopsys.com>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490118934.git.jpinto@synopsys.com>
 <14d56634-1ec0-2d21-4e60-c1adde5d42f5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <clabbe.montjoie@gmail.com>, <thierry.reding@gmail.com>,
        <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:39810 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759029AbdCVLHS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 07:07:18 -0400
In-Reply-To: <14d56634-1ec0-2d21-4e60-c1adde5d42f5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 6:56 PM de 3/21/2017, Florian Fainelli escreveu:
> On 03/21/2017 11:02 AM, Joao Pinto wrote:
>> This patch fixes a bug introduced in:
>> commit 6deee2221e11 ("net: stmmac: prepare dma op mode config for multiple
>> queues")
> 
> So even though this is against net-next which is the only tree so far
> having the offending commit, it is nice to see this appear later in the
> commit messages as:
> 
> Fixes: 6deee2221e11 ("net: stmmac: prepare dma op mode config for
> multiple queues")
> 
> Also, your subject for this patch should be:
> 
> net: stmmac: fix dma operation mode config for older versions

Ok, I will do that! Thanks.

> 
>>
>> The dma operation mode configuration routine was wrongly moved to a
>> function (stmmac_mtl_configuration) that is only executed if the
>> core version is >= 4.00.
>>
>> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index d3a2151..225a3a3 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1945,9 +1945,6 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
>>  	/* Enable MAC RX Queues */
>>  	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
>>  		stmmac_mac_enable_rx_queues(priv);
>> -
>> -	/* Set the HW DMA mode and the COE */
>> -	stmmac_dma_operation_mode(priv);
>>  }
>>  
>>  /**
>> @@ -2014,6 +2011,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>>  	else
>>  		stmmac_set_mac(priv->ioaddr, true);
>>  
>> +	/* Set the HW DMA mode and the COE */
>> +	stmmac_dma_operation_mode(priv);
>> +
>>  	stmmac_mmc_setup(priv);
>>  
>>  	if (init_ptp) {
>>
> 
> 
