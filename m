From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 15:28:59 +0200
Message-ID: <bac808d4-8c0e-c445-8478-262e691cf715@axis.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
 <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
 <20170325072621.GA20997@Red>
 <9f9f20d0-198b-6928-6c78-6982030f9101@synopsys.com>
 <20170327090941.GC12523@Red>
 <a4813594-191b-d374-27da-6c87b1c72e3e@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <sergei.shtylyov@cogentembedded.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:56520 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbdC0N3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 09:29:10 -0400
In-Reply-To: <a4813594-191b-d374-27da-6c87b1c72e3e@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/27/2017 11:12 AM, Joao Pinto wrote:
> Às 10:09 AM de 3/27/2017, Corentin Labbe escreveu:
>> On Mon, Mar 27, 2017 at 10:04:57AM +0100, Joao Pinto wrote:
>>> Às 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
>>>> On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
>>>>> For cores that have more than 1 TX queue configured, the kernel would crash,
>>>>> since only one TX queue is permitted by default.
>>>>>
>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>>> ---
>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> index 3827952..1eab084 100644
>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>>> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>>>>>  	struct stmmac_rx_queue *rx_q =
>>>>>  		container_of(napi, struct stmmac_rx_queue, napi);
>>>>>  	struct stmmac_priv *priv = rx_q->priv_data;
>>>>> -	u32 tx_count = priv->dma_cap.number_tx_queues;
>>>>> +	u32 tx_count = priv->plat->tx_queues_to_use;
>>>>>  	u32 chan = rx_q->queue_index;
>>>>>  	u32 work_done = 0;
>>>>>  	u32 queue = 0;
>>>>> -- 
>>>>> 2.9.3
>>>>>
>>>>
>>>> This patch fix the performance issue on dwmac-sun8i only.
>>>
>>> Ok, great!
>>>
>>
>> Sorry, in the we, I see that my gigabit dwmac-sun8i didnt work... (but didnt have time to find why).
>>
>>>> The dwmac-sunxi is still broken.
> 
> Ok, let's see what others report.
> 
>>>>
>>>
>>> What is the difference between the setups?
>>
>> dwmac-sun8i use chain mode, dwmac-sunxi use ring mode
>>
> 
> @Thierry and Niklas: Hi! Your setup is working well with these 2 fix patches?
> 

Hello Joao,

I have not tested these 2 patches.

Previously, when I tested next-20170321, artpec-6 SoC got TX queue timeouts.
When testing today's linux-next, next-20170327, things are working again :)


So I guess one of the following patches fixed our problem:

270c7759fbbc net: stmmac: add set_mac to the stmmac_ops
b4f0a6615556 net: stmmac: fix dma operation mode config for older versions
33e85b8dd69e net: stmmac: Restore DT backwards-compatibility
f39768744fd6 net: stmmac: Always enable MAC RX queues
abe80fdc6ee6 net: stmmac: RX queue routing configuration
a8f5102af2a7 net: stmmac: TX and RX queue priority configuration
aff3d9eff843 net: stmmac: enable multiple buffers

Regards,
Niklas
