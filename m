From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v6 net-next] ravb: Add dma queue interrupt support
Date: Wed, 2 Mar 2016 21:50:37 +0300
Message-ID: <56D735FD.10605@cogentembedded.com>
References: <1456674078-1316-1-git-send-email-ykaneko0929@gmail.com>
 <56D4AA63.6030203@cogentembedded.com>
 <CAH1o70JpRZAKSSPGe6MYfw0OGSaC9d7jDd9D71mn9bxLSy3qtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAH1o70JpRZAKSSPGe6MYfw0OGSaC9d7jDd9D71mn9bxLSy3qtQ@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2016 09:16 PM, Yoshihiro Kaneko wrote:

>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch supports the following interrupts.
>>>
>>> - One interrupt for multiple (timestamp, error, gPTP)
>>> - One interrupt for emac
>>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>>
>>> This patch improve efficiency of the interrupt handler by adding the
>>> interrupt handler corresponding to each interrupt source described
>>> above. Additionally, it reduces the number of times of the access to
>>> EthernetAVB IF.
>>> Also this patch prevent this driver depends on the whim of a boot loader.
>>>
>>> [ykaneko0929@gmail.com: define bit names of registers]
>>> [ykaneko0929@gmail.com: add comment for gen3 only registers]
>>> [ykaneko0929@gmail.com: fix coding style]
>>> [ykaneko0929@gmail.com: update changelog]
>>> [ykaneko0929@gmail.com: gen3: fix initialization of interrupts]
>>> [ykaneko0929@gmail.com: gen3: fix clearing interrupts]
>>> [ykaneko0929@gmail.com: gen3: add helper function for request_irq()]
>>> [ykaneko0929@gmail.com: gen3: remove IRQF_SHARED flag for request_irq()]
>>> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
>>> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked interrupts]
>>> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
>>> [ykaneko0929@gmail.com: make timestamp interrupt handler a function]
>>> [ykaneko0929@gmail.com: timestamp interrupt is handled in multiple
>>>    interrupt handler instead of dma queue interrupt handler]
>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>
>>     OK, you are very close now! Just a few comments...
>>
[...]
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>> index c936682..22ef65d 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>>
>>> +static irqreturn_t ravb_rx_tx_interrupt(int irq, void *dev_id, int
>>> ravb_queue)
>>
>>    Please, please shorten this 'ravb_queue'...
>
> I will fix it.
>
>>     Also, would make sense to rename it to ravb_dma_interrupt()...
>
> I have renamed it from ravb_dmaq_interrupt() in this version as you
> suggested in the previous review. Did you not mean it?

    Yes, I meant that, though perhaps got somewhat muddled up. Another variant 
is to call the current ravb_queue_interrupt() ravb_dma_interrupt_unlocked() 
(after adding the register reads there) calling this one ravb_dma_interrupt() 
but I don't insist on the former, ravb_queue_interrupt() is good enough as is; 
just rename this function please.

>> [...]
>>
>>     Unfortunately, I still can't do a full gen2 regression testing as both
>> Alt and Porter boards don't work with the recent kernel due to AVB_MDIO
>> stuck at 1... But perhaps such testing isn't even necessary.
>
> Thanks,
> kaneko

MBR, Sergei
