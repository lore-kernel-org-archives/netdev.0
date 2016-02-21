From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Sun, 21 Feb 2016 22:16:45 +0300
Message-ID: <56CA0D1D.2090903@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <56AA4674.6020001@cogentembedded.com>
 <CAH1o70LRuYwKGwhWBy1m6AuWfe-rNRBER7-Oi2u84ahX5+NyuA@mail.gmail.com>
 <56B77A57.2080902@cogentembedded.com>
 <CAH1o70JFUVaRb07ivtnZhOYNbh8n2mdZpH41nsMjEenx5yNeeQ@mail.gmail.com>
 <56C9DAF1.1030003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56C9DAF1.1030003@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21/2016 06:42 PM, Sergei Shtylyov wrote:

[...]

>>>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>>>
>>>>>> This patch supports the following interrupts.
>>>>>>
>>>>>> - One interrupt for multiple (descriptor, error, management)
>>>>>> - One interrupt for emac
>>>>>> - Four interrupts for dma queue (best effort rx/tx, network control
>>>>>> rx/tx)
>>>>>>
>>>>>> This patch improve efficiency of the interrupt handler by adding the
>>>>>> interrupt handler corresponding to each interrupt source described
>>>>>> above. Additionally, it reduces the number of times of the access to
>>>>>> EthernetAVB IF.
>>>>>>
>>>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

[...]

>>>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> index ac43ed9..076f25f 100644
>>>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>>>>> +                          struct net_device *ndev, struct device *dev,
>>>>>> +                          const char *ch)
>>>>>> +{
>>>>>> +       char *name;
>>>>>> +       int error;
>>>>>> +
>>>>>> +       name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
>>>>>> +       error = request_irq(irq, handler, IRQF_SHARED, name, ndev);
>>>>>
>>>>>      Not sure if we need IRQF_SHARED on those IRQs, they're not really
>>>>> shareable...
>>>>
>>>> I don't know whether this causes something bad.
>>>> I think this controller is supporting a shared IRQ.
>>>
>>>     Based on the high-level trigger, I'd rather suspect not. Anyway, all the
>>> SoC IRQs are dedicated to a certain (single) source.
>>
>> I don't want to change that if there is no fatal issue in the use of
>> IRQF_SHARED.
>> However, I will remove the flag if it is simple waste...
>
>     It's not a waste but it just shouldn't be needed.

    Actually for RX/TX DMA you're routing 2 interrupts to the same handler, so 
it's needed, sorry.

[...]

>> Thanks,
>> kaneko

MBR, Sergei
