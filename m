From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] [net-next] stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Fri, 31 Mar 2017 11:43:38 +0100
Message-ID: <5916d0ec-d427-08d2-908c-77667f6bf5cb@synopsys.com>
References: <20170328.180105.1996071259325891752.davem@davemloft.net>
 <20170330074536.GA4814@Red> <20170330143435.GA28098@ulmo.ba.sec>
 <20170330.104832.599422532945133952.davem@davemloft.net>
 <d262f8c8-28f4-d6f5-3c01-4bca114667dd@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <clabbe.montjoie@gmail.com>, <treding@nvidia.com>, <arnd@arndb.de>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d262f8c8-28f4-d6f5-3c01-4bca114667dd@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 11:14 AM de 3/31/2017, Joao Pinto escreveu:
> Às 6:48 PM de 3/30/2017, David Miller escreveu:
>> From: Thierry Reding <treding@nvidia.com>
>> Date: Thu, 30 Mar 2017 16:34:36 +0200
>>
>>> On Thu, Mar 30, 2017 at 09:45:36AM +0200, Corentin Labbe wrote:
>>>> On Tue, Mar 28, 2017 at 06:01:05PM -0700, David Miller wrote:
>>>>> From: Arnd Bergmann <arnd@arndb.de>
>>>>> Date: Tue, 28 Mar 2017 11:48:21 +0200
>>>>>
>>>>>> A driver must not access the two fields directly but should instead use
>>>>>> the helper functions to set the values and keep a consistent internal
>>>>>> state:
>>>>>>
>>>>>> ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
>>>>>> ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
>>>>>>
>>>>>> Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
>>>>>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>>>>>
>>>>> Applied.
>>>>
>>>> This break my revert patch. (since it patch ("net: stmmac: enable multiple buffers").
>>>> Since dwmac-sunxi is still broken, what can I do ? send two revert patch ? or adapt the reverting patch.
>>>
>>> Have you tried if the kcalloc() patch I sent on Tuesday fixes things the
>>> issues introduced by the multiple buffers patch? Niklas reported that it
>>> restores functionality on his setup.
>>
>> I think he said yesterday that he did indeed test all of your patches and it
>> did not fix things for him.
>>
>> http://marc.info/?l=linux-kernel&m=149076922813085&w=2
>>
>> I am going to revert the enable multiple buffers commit, and I would ask that
>> all involved parties work together in the background to resolve all of this.

@David: Could you please create a branch in your git tree for us to work on it
until the multiple buffers get stable for everyone? This way the patches could
circulate in the mailing-list with a different target, like stmmac-next or similar.

What do you think?

Joao

>>
>> Thank you.
>>
> 
> @David: Agreed.
> 
> @Corentin: Please check if the DMA Engine is well configured and if the dma
> rx/tx has started. This is done by dumping the DMA Registers.
> Please also check the MAC related registers and dump them in order to have a
> clear picture if the IP is being well configured.
> This is critial to analise what's hapenning in your setup.
> 
> Joao
> 
