From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Mon, 27 Mar 2017 16:26:48 +0100
Message-ID: <74765cbf-897a-67a1-7f42-337bf7dff6a8@synopsys.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
 <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
 <20170325072621.GA20997@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <thierry.reding@gmail.com>, <sergei.shtylyov@cogentembedded.com>,
        <f.fainelli@gmail.com>, <niklas.cassel@axis.com>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:34869 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdC0P0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 11:26:54 -0400
In-Reply-To: <20170325072621.GA20997@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Às 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
> On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
>> For cores that have more than 1 TX queue configured, the kernel would crash,
>> since only one TX queue is permitted by default.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 3827952..1eab084 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>>  	struct stmmac_rx_queue *rx_q =
>>  		container_of(napi, struct stmmac_rx_queue, napi);
>>  	struct stmmac_priv *priv = rx_q->priv_data;
>> -	u32 tx_count = priv->dma_cap.number_tx_queues;
>> +	u32 tx_count = priv->plat->tx_queues_to_use;
>>  	u32 chan = rx_q->queue_index;
>>  	u32 work_done = 0;
>>  	u32 queue = 0;
>> -- 
>> 2.9.3
>>
> 
> This patch fix the performance issue on dwmac-sun8i only.
> The dwmac-sunxi is still broken.
> 

This patch series can be upstreamed please, since they make 2 fixes, one of them
solving the problem in dwmac-sun8i.

Thanks.
