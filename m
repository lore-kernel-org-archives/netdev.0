From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Mon, 8 Feb 2016 01:56:40 +0900
Message-ID: <CAH1o70+WbQ8qRtO9nez1aooCLVTX30Z1G4MBJPmTCKCpMNzqxw@mail.gmail.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
	<56AA50A5.5080504@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <56AA50A5.5080504@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-01-29 2:32 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> On 01/24/2016 06:52 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (descriptor, error, management)
>> - One interrupt for emac
>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>> This patch improve efficiency of the interrupt handler by adding the
>> interrupt handler corresponding to each interrupt source described
>> above. Additionally, it reduces the number of times of the access to
>> EthernetAVB IF.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index ac43ed9..076f25f 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>
>> @@ -1215,29 +1332,64 @@ static const struct ethtool_ops ravb_ethtool_ops =
>> {
>>         .get_ts_info            = ravb_get_ts_info,
>>   };
>>
>> +static inline int hook_irq(unsigned int irq, irq_handler_t handler,
>> +                          struct net_device *ndev, struct device *dev,
>> +                          const char *ch)
>> +{
>> +       char *name;
>> +       int error;
>> +
>> +       name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
>
>
>    BTW, shouldn't we test 'name' for NULL here?

Thanks.
I will fix it to return -ENOMEM if 'name' is NULL.

>
>> +       error = request_irq(irq, handler, IRQF_SHARED, name, ndev);
>> +       if (error)
>> +               netdev_err(ndev, "cannot request IRQ %s\n", name);
>> +
>> +       return error;
>> +}
>> +
>
>
> MBR, Sergei
>

Thanks,
kaneko
