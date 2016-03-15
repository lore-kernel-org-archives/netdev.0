From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v7 net-next] ravb: Add dma queue interrupt support
Date: Tue, 15 Mar 2016 20:08:02 +0300
Message-ID: <56E84172.3070508@cogentembedded.com>
References: <1457892712-29024-1-git-send-email-ykaneko0929@gmail.com>
 <56E72394.5030905@cogentembedded.com>
 <CAH1o70JC_OGqdUEXjGFMm1EDdVAEkGaMiJrx2JTgW+Ny1FnC3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAH1o70JC_OGqdUEXjGFMm1EDdVAEkGaMiJrx2JTgW+Ny1FnC3A@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/15/2016 06:03 PM, Yoshihiro Kaneko wrote:

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
>> [...]
>>>
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>> index 8f2c4fb..8fa8ffe 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>>
>> [...]
>>>
>>> @@ -757,14 +806,73 @@ static irqreturn_t ravb_interrupt(int irq, void
>>> *dev_id)
>>>                  result = IRQ_HANDLED;
>>>          }
>>>
>>> -       if (iss & ISS_CGIS)
>>> -               result = ravb_ptp_interrupt(ndev);
>>> +       /* gPTP interrupt status summary */
>>> +       if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
>>> +               result = IRQ_HANDLED;
>>
>>     Wait, this seems like a bug in the existing driver! Please do fix it with
>> a separate patch against net.git. Sorry about missing (or even adding) it
>> while cleaning up the driver before submission...

> Thanks, I will do so.

    TIA.

>>
>> [...]
>>
>>     Looks fine otherwise, however the new features and the fixes shouldn't be
>> mixed together, so I couldn't ACK yet. I'll go test it on gen2...
>
> Thanks in advance.

    My testing on the modified Porter board went smooth.

> Thanks,
> kaneko

MBR, Sergei
