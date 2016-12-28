From: Kishan Sandeep <sandeepkishan108@gmail.com>
Subject: Re: [PATCH v3] stmmac: enable rx queues
Date: Wed, 28 Dec 2016 17:32:40 +0530
Message-ID: <CAJ3s=NCGnzgfWF2T5d=OSD4qSPpSnP=E4ioAmLbdFFR23m4zoQ@mail.gmail.com>
References: <f159542b43e49004ab63aaaf1a1c5cc5cbb2dfa7.1482922898.git.jpinto@synopsys.com>
 <CAJ3s=NB-ic4OrXPVPpYyoYrEwfwCmrAB8ZNPorpyU+5Do_b2=g@mail.gmail.com> <089cbc8f-ed57-f5e5-51a7-c62e37998f6c@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:34020 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbcL1MCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:02:42 -0500
Received: by mail-ua0-f196.google.com with SMTP id i68so19538106uad.1
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 04:02:41 -0800 (PST)
In-Reply-To: <089cbc8f-ed57-f5e5-51a7-c62e37998f6c@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 28, 2016 at 5:23 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote=
:
> Hello,
>
> =C3=80s 11:50 AM de 12/28/2016, Kishan Sandeep escreveu:
>> On Wed, Dec 28, 2016 at 4:45 PM, Joao Pinto <Joao.Pinto@synopsys.com> wr=
ote:
>>
>>> When the hardware is synthesized with multiple queues, all queues are
>>> disabled for default. This patch adds the rx queues configuration.
>>> This patch was successfully tested in a Synopsys QoS Reference design.
>>>
>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>> ---
>>> changes v2 -> v3 (Seraphin Bonnaffe):
>>> - GMAC_RX_QUEUE_CLEAR macro simplified
>>> changes v1 -> v2 (Niklas Cassel and Seraphin Bonnaffe):
>>> - Instead of using number of DMA channels, lets use number of queues
>>> - Create 2 flavors of RX queue enable Macros: AV and DCB (AV by default=
)
>>> - Make sure that the RX queue related bits are cleared before setting
>>> - Check if rx_queue_enable is available before executing
>>>
>>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  5 +++++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  8 ++++++++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 12 ++++++++++++
>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  |  5 +++++
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 22
>>> ++++++++++++++++++++++
>>>  5 files changed, 52 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> index b13a144..6c96291 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>> @@ -323,6 +323,9 @@ struct dma_features {
>>>         /* TX and RX number of channels */
>>>         unsigned int number_rx_channel;
>>>         unsigned int number_tx_channel;
>>> +       /* TX and RX number of queues */
>>> +       unsigned int number_rx_queues;
>>> +       unsigned int number_tx_queues;
>>>
>>
>> Looks like this variable is unused. Current driver is only supporting
>> single Tx channel/queue. ??  Is current driver not supporting
>> multichannel/multiqueue ?
>
> stmmac has a good base for multichannel / multiple queue support, but is =
only
> using 1 for now. My next task is to add complete multiple queues / channe=
l to
> stmmac amd that is why number of tx queues is being available.
>
> Thanks!

I believe *number_tx_queues* variable can be added at the time support
we are providing.

One query is that what is the algorithm that we are following
currently in the driver if we enable multi Rx queues/DMA channels ?

Thanks!
