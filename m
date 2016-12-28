From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v3] stmmac: enable rx queues
Date: Wed, 28 Dec 2016 12:26:13 +0000
Message-ID: <31dafcf4-5136-02b0-ab21-c56725c6a68a@synopsys.com>
References: <f159542b43e49004ab63aaaf1a1c5cc5cbb2dfa7.1482922898.git.jpinto@synopsys.com>
 <CAJ3s=NB-ic4OrXPVPpYyoYrEwfwCmrAB8ZNPorpyU+5Do_b2=g@mail.gmail.com>
 <089cbc8f-ed57-f5e5-51a7-c62e37998f6c@synopsys.com>
 <CAJ3s=NCGnzgfWF2T5d=OSD4qSPpSnP=E4ioAmLbdFFR23m4zoQ@mail.gmail.com>
 <540e62c2-0031-6263-3299-3e7c192812fa@synopsys.com>
 <CAJ3s=NA0d=NAOPnWA2S9B_X2z9H6++wrH7nNyTv8Gbh_E_dmYg@mail.gmail.com>
 <24c21cfd-87f5-2cae-6db1-32edc3333471@synopsys.com>
 <389b0a01-1b17-c0f6-140f-bcd42c854480@synopsys.com>
 <CAJ3s=NCs5j_iWkYTyNto6UaX-bmLjXVYu6DGKXQNfbafa5AVvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Kishan Sandeep <sandeepkishan108@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:41293 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbcL1MeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:34:10 -0500
In-Reply-To: <CAJ3s=NCs5j_iWkYTyNto6UaX-bmLjXVYu6DGKXQNfbafa5AVvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 12:23 PM de 12/28/2016, Kishan Sandeep escreveu:
> On Dec 28, 2016 5:50 PM, "Joao Pinto" <Joao.Pinto@synopsys.com> wrote:
>>
>> Às 12:19 PM de 12/28/2016, Joao Pinto escreveu:
>>> Às 12:15 PM de 12/28/2016, Kishan Sandeep escreveu:
>>>> On Dec 28, 2016 5:36 PM, "Joao Pinto" <Joao.Pinto@synopsys.com> wrote:
>>>>>
>>>>> Às 12:02 PM de 12/28/2016, Kishan Sandeep escreveu:
>>>>>> On Wed, Dec 28, 2016 at 5:23 PM, Joao Pinto <Joao.Pinto@synopsys.com>
>>>> wrote:
>>>>>>> Hello,
>>>>>>>
>>>>>>> Às 11:50 AM de 12/28/2016, Kishan Sandeep escreveu:
>>>>>>>> On Wed, Dec 28, 2016 at 4:45 PM, Joao Pinto <
> Joao.Pinto@synopsys.com>
>>>> wrote:
>>>>>>>>
>>>>>>>>> When the hardware is synthesized with multiple queues, all queues
> are
>>>>>>>>> disabled for default. This patch adds the rx queues configuration.
>>>>>>>>> This patch was successfully tested in a Synopsys QoS Reference
>>>> design.
>>>>>>>>>
>>>>>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>>>>>>> ---
>>>>>>>>> changes v2 -> v3 (Seraphin Bonnaffe):
>>>>>>>>> - GMAC_RX_QUEUE_CLEAR macro simplified
>>>>>>>>> changes v1 -> v2 (Niklas Cassel and Seraphin Bonnaffe):
>>>>>>>>> - Instead of using number of DMA channels, lets use number of
> queues
>>>>>>>>> - Create 2 flavors of RX queue enable Macros: AV and DCB (AV by
>>>> default)
>>>>>>>>> - Make sure that the RX queue related bits are cleared before
> setting
>>>>>>>>> - Check if rx_queue_enable is available before executing
>>>>>>>>>
>>>>>>>>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  5 +++++
>>>>>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  8 ++++++++
>>>>>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 12
> ++++++++++++
>>>>>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  |  5 +++++
>>>>>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 22
>>>>>>>>> ++++++++++++++++++++++
>>>>>>>>>  5 files changed, 52 insertions(+)
>>>>>>>>>
>>>>>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
>>>>>>>>> b/drivers/net/ethernet/stmicro/stmmac/common.h
>>>>>>>>> index b13a144..6c96291 100644
>>>>>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>>>>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>>>>>>>> @@ -323,6 +323,9 @@ struct dma_features {
>>>>>>>>>         /* TX and RX number of channels */
>>>>>>>>>         unsigned int number_rx_channel;
>>>>>>>>>         unsigned int number_tx_channel;
>>>>>>>>> +       /* TX and RX number of queues */
>>>>>>>>> +       unsigned int number_rx_queues;
>>>>>>>>> +       unsigned int number_tx_queues;
>>>>>>>>>
>>>>>>>>
>>>>>>>> Looks like this variable is unused. Current driver is only
> supporting
>>>>>>>> single Tx channel/queue. ??  Is current driver not supporting
>>>>>>>> multichannel/multiqueue ?
>>>>>>>
>>>>>>> stmmac has a good base for multichannel / multiple queue support,
> but
>>>> is only
>>>>>>> using 1 for now. My next task is to add complete multiple queues /
>>>> channel to
>>>>>>> stmmac amd that is why number of tx queues is being available.
>>>>>>>
>>>>>>> Thanks!
>>>>>>
>>>>>> I believe *number_tx_queues* variable can be added at the time
> support
>>>>>> we are providing.
>>>>>>
>>>>>> One query is that what is the algorithm that we are following
>>>>>> currently in the driver if we enable multi Rx queues/DMA channels ?
>>>>>
>>>>> In a synthesized core with single channel, multi dma/queues is not an
>>>> issue
>>>>> since it has a single queue and that's it. For a synthesized core with
>>>> multiple
>>>>> there are some algorithms that can be configured in the driver. I will
>>>> include
>>>>> them later. I can change this patch and enale rx queue 0 only, no
> problem.
>>>>
>>>> Generally there will be one to one mapping from the DMA channel to
>>>> corresponding MTL queue. If we enable multiple MTL RX queues, is there
> any
>>>> requirement to use those many number of DMA channels in RX path or
> single
>>>> DMA RX channel is sufficient ???
>>>
>>> I am using an ethernet QoS reference design synthesized  with 4
> channels / 4
>>> queues. Since stmmac only uses one 1 queue / 1 dma channel. Of course
> the
>>> performance is not the same as using the 4 available ones. I would say
> the
>>> correct approach would be tp get the available rx/tx dma channel number
> and
>>> rx/tx queue number configured in the hardware and get the driver adapt
> and use
>>> as many as there are.
>>
>> Of course there should be always dma  channels = queues.
>>
>>>
>>>>
>>>
> In that case here we need to enable multi DMA channels along with multiple
> RX channels also we may need to program the algorithm that needs to run on
> queues

I understand your concern. In order to do this step by step, I am going to
change the patch and enable RX queue 0 only, and then when I finish multiple
support I will add multi rx and tx. I will send a v4 in the afternoon. This way
it will be cleaner and less confusing.

Thanks.
