From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Sun, 7 Feb 2016 20:18:00 +0300
Message-ID: <56B77C48.3010900@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <56AA50A5.5080504@cogentembedded.com>
 <CAH1o70+WbQ8qRtO9nez1aooCLVTX30Z1G4MBJPmTCKCpMNzqxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAH1o70+WbQ8qRtO9nez1aooCLVTX30Z1G4MBJPmTCKCpMNzqxw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2016 07:56 PM, Yoshihiro Kaneko wrote:

>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch supports the following interrupts.
>>>
>>> - One interrupt for multiple (descriptor, error, management)
>>> - One interrupt for emac
>>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>>
>>> This patch improve efficiency of the interrupt handler by adding the
>>> interrupt handler corresponding to each interrupt source described
>>> above. Additionally, it reduces the number of times of the access to
>>> EthernetAVB IF.
>>>
>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>
>>
>> [...]
>>
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>> index ac43ed9..076f25f 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>>
>> [...]
>>>
>>> @@ -1215,29 +1332,64 @@ static const struct ethtool_ops ravb_ethtool_ops =
>>> {
>>>          .get_ts_info            = ravb_get_ts_info,
>>>    };
>>>
>>> +static inline int hook_irq(unsigned int irq, irq_handler_t handler,
>>> +                          struct net_device *ndev, struct device *dev,
>>> +                          const char *ch)
>>> +{
>>> +       char *name;
>>> +       int error;
>>> +
>>> +       name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
>>
>>
>>     BTW, shouldn't we test 'name' for NULL here?
>
> Thanks.
> I will fix it to return -ENOMEM if 'name' is NULL.

    Be sure to use '!name' -- it's preferred in the networking code.

> Thanks,
> kaneko

MBR, Sergei

