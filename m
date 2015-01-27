From: Eugene Krasnikov <k.eugene.e@gmail.com>
Subject: Re: [PATCH 2/2] net wireless wcn36xx adapt wcnss platform to select
 module by DT
Date: Tue, 27 Jan 2015 20:27:26 +0000
Message-ID: <CAFSJ42a7kuPfJfhiDSD5C+z4GqiX-CHOrdmAT=n6rdsPtsWMEQ@mail.gmail.com>
References: <20150118051222.32019.32719.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051650.32019.49483.stgit@114-36-241-182.dynamic.hinet.net>
	<CAFSJ42YW5RNpeWA-VDjUT9Ct0MSCxaLNY8XQHUdo9NKzLbCjMg@mail.gmail.com>
	<CAAfg0W6osNyLB1zPbbhVwQV1OsP_1K1stUK8zkyZygavNjmxGw@mail.gmail.com>
	<CAFSJ42b2WaYcbvaW1RmBLdfU9t4C0ALXM_n_T=VXygpYNPPp9w@mail.gmail.com>
	<CAAfg0W4uPeSUxngVB5nU3y66JNDUA4TrZ_J2eALwcpKryKiMQg@mail.gmail.com>
	<CAFSJ42bK1WbCCBhsuKbOjh0TR7y3GwMibwkRKgiPRY=PW519Cw@mail.gmail.com>
	<CAAfg0W6TWxi7Lp_nZZ7peuHvuYfBckeqRQaeo42snG=z2pMeag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:59182 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbbA0U11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:27:27 -0500
In-Reply-To: <CAAfg0W6TWxi7Lp_nZZ7peuHvuYfBckeqRQaeo42snG=z2pMeag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What i mean is that it's not clear who knows what chip is this,
whether wcn36xx or wcn36xx_msm. Previously the assumption was that SMD
command will tell what interface to use. Now we are moving towards
wcn36xx_msm telling what chip is installed. Both approaches will work.
If it less work to do then fine.

Sorry for any confusion.

2015-01-19 9:34 GMT+00:00 Andy Green <andy.green@linaro.org>:
> On 19 January 2015 at 17:02, Eugene Krasnikov <k.eugene.e@gmail.com> wrote:
>> The idea is definitely better than just checking for AC support. But
>> the question is whether platform/hardware/firmware support that?
>
> Sorry I don't understand what might be unsupported.
>
>  - We don't ask the firmware, we tell the driver what chip it is from
> the outside.  There's nothing for the firmware to support.
>
>  - Platform supports a set of ops via platform_data already.  This
> just adds one op to get the chip type from the platform code.
>
>  - What can't the hardware support?  The hardware physically is a
> 3620, 3660 or 3680.  We just tell the driver what it is when we
> instantiate the device.  We don't ask anything of the hardware.
>
> I expected to have a debate about whether to move the dt support to
> wcn36xx directly which is also reasonable... there's no question
> adding an op will work or not, it will work for all cases like this.
> But it also implies there must be the "device faking" business in -msm
> code, one day that will also go upstream and then it might be
> considered a bit strange.
>
> I did it like this now because it's the minimum change from the
> current situation.
>
> -Andy
>
>> 2015-01-19 9:00 GMT+00:00 Andy Green <andy.green@linaro.org>:
>>> On 19 January 2015 at 16:49, Eugene Krasnikov <k.eugene.e@gmail.com> wrote:
>>>> Have you tested this code on any device other than wcn3620?
>>>
>>> No... the only hardware I have is 3620.  But the only code we're
>>> adding to mainline is the patch with the ops to get the chip type.
>>>
>>> The two-patch series just shows one way to set that (which will
>>> certainly work for all three defined compatible types, if it works for
>>> one).  And this code cannot go upstream.
>>>
>>> So the only decision to make is around whether adding the platform op
>>> is a good way (or, eg, directly add DT support to wcn36xx and
>>> eliminate the 'device regeneration' part of the OOT -msm code).
>>>
>>> At the moment the detect code does not work for 3620, so something
>>> needs to be done.
>>>
>>> -Andy
>>>
>>>> 2015-01-19 8:44 GMT+00:00 Andy Green <andy.green@linaro.org>:
>>>>> On 19 January 2015 at 16:34, Eugene Krasnikov <k.eugene.e@gmail.com> wrote:
>>>>>
>>>>>> So how do we insmod wcn36xx_msm with a parameter specifying what type
>>>>>> of hardware do we use?
>>>>>
>>>>> The type of chip is defined in the DT "compatible" which also delivers
>>>>> the resource information.
>>>>>
>>>>>         qcom,wcn36xx@0a000000 {
>>>>>                 compatible = "qcom,wcn3620";
>>>>>                 reg = <0x0a000000 0x280000>;
>>>>>                 reg-names = "wcnss_mmio";
>>>>>
>>>>>                 interrupts = <0 145 0 0 146 0>;
>>>>>                 interrupt-names = "wcnss_wlantx_irq", "wcnss_wlanrx_irq";
>>>>> ...
>>>>>
>>>>> This bit based on your code can't go in mainline until there's some
>>>>> kind of PIL support.
>>>>>
>>>>> So the only things we can discuss about it for mainline purpose is
>>>>> whether using a platform ops is a good way to interface to the
>>>>> mainline driver.
>>>>>
>>>>> If you're OK with that and you want a module parameter then this can
>>>>> grow a module parameter and prefer to deliver the chip type from that
>>>>> if given, without modifying the platform op interface.
>>>>>
>>>>> But with or without a module parameter this can't be upstreamed right
>>>>> now due to PIL.
>>>>>
>>>>> -Andy
>>>>>
>>>>>> 2015-01-18 5:16 GMT+00:00 Andy Green <andy.green@linaro.org>:
>>>>>>> Simplify the resource handling and use DT to indicate which chip type
>>>>>>> we are dealing with
>>>>>>>
>>>>>>> Signed-off-by: Andy Green <andy.green@linaro.org>
>>>>>>> ---
>>>>>>>  drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c |  101 ++++++++++++------------
>>>>>>>  1 file changed, 52 insertions(+), 49 deletions(-)
>>>>>>>
>>>>>>> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c b/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
>>>>>>> index f6f6c83..c9250e0 100644
>>>>>>> --- a/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
>>>>>>> +++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
>>>>>>> @@ -42,7 +42,10 @@ struct wcn36xx_msm {
>>>>>>>         struct completion       smd_compl;
>>>>>>>         smd_channel_t           *smd_ch;
>>>>>>>         struct pinctrl *pinctrl;
>>>>>>> -} wmsm;
>>>>>>> +       enum wcn36xx_chip_type chip_type;
>>>>>>> +};
>>>>>>> +
>>>>>>> +static struct wcn36xx_msm wmsm;
>>>>>>>
>>>>>>>  static int wcn36xx_msm_smsm_change_state(u32 clear_mask, u32 set_mask)
>>>>>>>  {
>>>>>>> @@ -217,14 +220,47 @@ int wcn36xx_msm_powerup(const struct subsys_desc *desc)
>>>>>>>         return 0;
>>>>>>>  }
>>>>>>>
>>>>>>> +static const struct of_device_id wcn36xx_msm_match_table[] = {
>>>>>>> +       { .compatible = "qcom,wcn3660", .data = (void *)WCN36XX_CHIP_3660 },
>>>>>>> +       { .compatible = "qcom,wcn3680", .data = (void *)WCN36XX_CHIP_3680 },
>>>>>>> +       { .compatible = "qcom,wcn3620", .data = (void *)WCN36XX_CHIP_3620 },
>>>>>>> +       { }
>>>>>>> +};
>>>>>>> +
>>>>>>> +static int wcn36xx_msm_get_chip_type(void)
>>>>>>> +{
>>>>>>> +       return wmsm.chip_type;
>>>>>>> +}
>>>>>>> +
>>>>>>> +static struct wcn36xx_msm wmsm = {
>>>>>>> +       .ctrl_ops = {
>>>>>>> +               .open = wcn36xx_msm_smd_open,
>>>>>>> +               .close = wcn36xx_msm_smd_close,
>>>>>>> +               .tx = wcn36xx_msm_smd_send_and_wait,
>>>>>>> +               .get_hw_mac = wcn36xx_msm_get_hw_mac,
>>>>>>> +               .smsm_change_state = wcn36xx_msm_smsm_change_state,
>>>>>>> +               .get_chip_type = wcn36xx_msm_get_chip_type,
>>>>>>> +       },
>>>>>>> +};
>>>>>>> +
>>>>>>>  static int wcn36xx_msm_probe(struct platform_device *pdev)
>>>>>>>  {
>>>>>>>         int ret;
>>>>>>> -       struct resource *wcnss_memory;
>>>>>>> -       struct resource *tx_irq;
>>>>>>> -       struct resource *rx_irq;
>>>>>>> +       const struct of_device_id *of_id;
>>>>>>> +       struct resource *r;
>>>>>>>         struct resource res[3];
>>>>>>>         struct pinctrl_state *ps;
>>>>>>> +       static const char const *rnames[] = {
>>>>>>> +               "wcnss_mmio", "wcnss_wlantx_irq", "wcnss_wlanrx_irq" };
>>>>>>> +       static const int rtype[] = {
>>>>>>> +               IORESOURCE_MEM, IORESOURCE_IRQ, IORESOURCE_IRQ };
>>>>>>> +       int n;
>>>>>>> +
>>>>>>> +       of_id = of_match_node(wcn36xx_msm_match_table, pdev->dev.of_node);
>>>>>>> +       if (!of_id)
>>>>>>> +               return -EINVAL;
>>>>>>> +
>>>>>>> +       wmsm.chip_type = (enum wcn36xx_chip_type)of_id->data;
>>>>>>>
>>>>>>>         wmsm.pinctrl = devm_pinctrl_get(&pdev->dev);
>>>>>>>         if (IS_ERR_OR_NULL(wmsm.pinctrl))
>>>>>>> @@ -240,52 +276,23 @@ static int wcn36xx_msm_probe(struct platform_device *pdev)
>>>>>>>
>>>>>>>         if (IS_ERR_OR_NULL(pil))
>>>>>>>                 pil = subsystem_get("wcnss");
>>>>>>> -               if (IS_ERR_OR_NULL(pil))
>>>>>>> -                       return PTR_ERR(pil);
>>>>>>> +       if (IS_ERR_OR_NULL(pil))
>>>>>>> +               return PTR_ERR(pil);
>>>>>>>
>>>>>>>         wmsm.core = platform_device_alloc("wcn36xx", -1);
>>>>>>>
>>>>>>> -       //dev_err(&pdev->dev, "%s starting\n", __func__);
>>>>>>> -
>>>>>>> -       memset(res, 0x00, sizeof(res));
>>>>>>> -       wmsm.ctrl_ops.open = wcn36xx_msm_smd_open;
>>>>>>> -       wmsm.ctrl_ops.close = wcn36xx_msm_smd_close;
>>>>>>> -       wmsm.ctrl_ops.tx = wcn36xx_msm_smd_send_and_wait;
>>>>>>> -       wmsm.ctrl_ops.get_hw_mac = wcn36xx_msm_get_hw_mac;
>>>>>>> -       wmsm.ctrl_ops.smsm_change_state = wcn36xx_msm_smsm_change_state;
>>>>>>> -       wcnss_memory =
>>>>>>> -               platform_get_resource_byname(pdev,
>>>>>>> -                                             IORESOURCE_MEM,
>>>>>>> -                                             "wcnss_mmio");
>>>>>>> -       if (wcnss_memory == NULL) {
>>>>>>> -               dev_err(&wmsm.core->dev,
>>>>>>> -                       "Failed to get wcnss wlan memory map.\n");
>>>>>>> -               ret = -ENOMEM;
>>>>>>> -               return ret;
>>>>>>> -       }
>>>>>>> -       memcpy(&res[0], wcnss_memory, sizeof(*wcnss_memory));
>>>>>>> -
>>>>>>> -       tx_irq = platform_get_resource_byname(pdev,
>>>>>>> -                                             IORESOURCE_IRQ,
>>>>>>> -                                             "wcnss_wlantx_irq");
>>>>>>> -       if (tx_irq == NULL) {
>>>>>>> -               dev_err(&wmsm.core->dev, "Failed to get wcnss tx_irq");
>>>>>>> -               ret = -ENOMEM;
>>>>>>> -               return ret;
>>>>>>> -       }
>>>>>>> -       memcpy(&res[1], tx_irq, sizeof(*tx_irq));
>>>>>>> -
>>>>>>> -       rx_irq = platform_get_resource_byname(pdev,
>>>>>>> -                                             IORESOURCE_IRQ,
>>>>>>> -                                             "wcnss_wlanrx_irq");
>>>>>>> -       if (rx_irq == NULL) {
>>>>>>> -               dev_err(&wmsm.core->dev, "Failed to get wcnss rx_irq");
>>>>>>> -               ret = -ENOMEM;
>>>>>>> -               return ret;
>>>>>>> +       for (n = 0; n < ARRAY_SIZE(rnames); n++) {
>>>>>>> +               r = platform_get_resource_byname(pdev, rtype[n], rnames[n]);
>>>>>>> +               if (!r) {
>>>>>>> +                       dev_err(&wmsm.core->dev,
>>>>>>> +                               "Missing resource %s'\n", rnames[n]);
>>>>>>> +                       ret = -ENOMEM;
>>>>>>> +                       return ret;
>>>>>>> +               }
>>>>>>> +               res[n] = *r;
>>>>>>>         }
>>>>>>> -       memcpy(&res[2], rx_irq, sizeof(*rx_irq));
>>>>>>>
>>>>>>> -       platform_device_add_resources(wmsm.core, res, ARRAY_SIZE(res));
>>>>>>> +       platform_device_add_resources(wmsm.core, res, n);
>>>>>>>
>>>>>>>         ret = platform_device_add_data(wmsm.core, &wmsm.ctrl_ops,
>>>>>>>                                        sizeof(wmsm.ctrl_ops));
>>>>>>> @@ -319,10 +326,6 @@ static int wcn36xx_msm_remove(struct platform_device *pdev)
>>>>>>>         return 0;
>>>>>>>  }
>>>>>>>
>>>>>>> -static const struct of_device_id wcn36xx_msm_match_table[] = {
>>>>>>> -       { .compatible = "qcom,wcn36xx" },
>>>>>>> -       { }
>>>>>>> -};
>>>>>>>  MODULE_DEVICE_TABLE(of, wcn36xx_msm_match_table);
>>>>>>>
>>>>>>>  static struct platform_driver wcn36xx_msm_driver = {
>>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>> --
>>>>>> Best regards,
>>>>>> Eugene
>>>>
>>>>
>>>>
>>>> --
>>>> Best regards,
>>>> Eugene
>>
>>
>>
>> --
>> Best regards,
>> Eugene



-- 
Best regards,
Eugene
