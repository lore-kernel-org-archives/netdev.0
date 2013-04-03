From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Wed, 03 Apr 2013 09:41:16 +0200
Message-ID: <515BDD1C.5010306@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com> <1364972715.5113.197.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:46072 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761803Ab3DCHlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:41:25 -0400
In-Reply-To: <1364972715.5113.197.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 9:05 AM, Eric Dumazet wrote:
> On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
>> This patch is to:
>> o use napi_gro_flush() before calling __napi_complete()
>> o turn on NETIF_F_GRO by default
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>>   1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 6b26d31..8b69e3b 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2046,7 +2046,8 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>>
>>   	work_done = stmmac_rx(priv, budget);
>>   	if (work_done < budget) {
>> -		napi_complete(napi);
>> +		napi_gro_flush(napi, false);
>> +		__napi_complete(napi);
>>   		stmmac_enable_dma_irq(priv);
>>   	}
>
> Why are you doing this ?
>
> This adds a (fatal) race.

Hmm, I'm in trouble on this :-). Indeed I can understand the (fatal)
race and why napi_complete should be used. Sorry! So my fault and this 
patch has to be discarded. I don't understand why I have not seen any
problems while running/stressing on SMP system. Have you got any idea?

Thanks Eric for your prompt feedback.
Let me know if you see other problems so I'll try to fix all soon.

peppe
