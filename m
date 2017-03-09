From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next 2/8] net: stmicro: configure mtl rx and tx
 algorithms
Date: Thu, 9 Mar 2017 09:53:12 +0000
Message-ID: <fb8e92f3-b834-9f0c-5baf-82956001ca84@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
 <02bee5939abb88be5db27752e2469bc756cf36b9.1488975090.git.jpinto@synopsys.com>
 <0f6466c7-74a1-ae62-1fa4-16bc73f8c6c8@axis.com>
 <d8a865ef-5756-fc52-d524-be54f6265e55@synopsys.com>
 <936a80cb-4152-aeb0-8c5e-e4fc48b57b74@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:55731 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbdCIJyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 04:54:13 -0500
In-Reply-To: <936a80cb-4152-aeb0-8c5e-e4fc48b57b74@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 9:37 AM de 3/9/2017, Niklas Cassel escreveu:
> On 03/08/2017 05:48 PM, Joao Pinto wrote:
>> Às 4:45 PM de 3/8/2017, Niklas Cassel escreveu:
>>> On 03/08/2017 01:22 PM, Joao Pinto wrote:
>>>> This patch adds the RX and TX scheduling algorithms programming.
>>>> It introduces the multiple queues configuration function
>>>> (stmmac_mtl_configuration) in stmmac_main.
>>>>

(snip...)


>>>> +		stmmac_mac_enable_rx_queues(priv);
>>> Hello Joao
>>>
>>> Since you are now enabling RX queues here,
>>> perhaps we should move the enabling of TX queue(s) here as well?
>> Hi Niklas,
>> TX enable operation is different, it is part of the DMA Operation Mode
>> configuration. In a later patch I will be updating the DMA Operation Mode
>> configuration and this op will be placed here.
>>
>> As indicated by David Miller, this patch-set is focused in MAC ops only. DMA
>> focused patch-set will follow after this one gets accepted.
> 
> Not sure that I agree 100% since:
> 
> "23.2 Initializing MTL Registers"
> 
> 1. Program the Tx Scheduling algorithm. (Which you now do in stmmac_mtl_configuration.)
> 
> [snip]
> 
> 3. Program the following fields to initialize the mode of operation in the MTL_TxQ0_Operation_Mode
> a. Transmit Store And Forward (TSF) or Transmit Threshold Control (TTC) in case of threshold mode
> b. Transmit Queue Enable (TXQEN) to value 2‘b10 to enable Transmit Queue0
> c. Transmit Queue Size (TQS)
> 
> 
> Note that "Initializing DMA" is a separate chapter.
> 
> However, since you are planning on moving the MTL_TxQ0_Operation_Mode initialization
> to stmmac_mtl_configuration in a later patch, I don't think that you have to rework this
> patch just because of this simple remark.

Sorry, I misleaded you. What I was trying to say was that the TX Operation Mode
is going to be moved here in a later patch.

Thanks for the help.

> 
> Nice to see some work done on multiqueues for stmmac :)
> 
> 
>>
>> Thanks!
>>
>>>
>>>> +}
>>>> +
>>>> +/**
>>>>   * stmmac_hw_setup - setup mac in a usable state.
>>>>   *  @dev : pointer to the device structure.
>>>>   *  Description:
>>>> @@ -1688,9 +1713,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>>>>  	/* Initialize the MAC Core */
>>>>  	priv->hw->mac->core_init(priv->hw, dev->mtu);
>>>>  
>>>> -	/* Initialize MAC RX Queues */
>>>> -	if (priv->hw->mac->rx_queue_enable)
>>>> -		stmmac_mac_enable_rx_queues(priv);
>>>> +	/* Initialize MTL*/
>>>> +	if (priv->synopsys_id >= DWMAC_CORE_4_00)
>>>> +		stmmac_mtl_configuration(priv);
>>>>  
>>>>  	ret = priv->hw->mac->rx_ipc(priv->hw);
>>>>  	if (!ret) {
> 
