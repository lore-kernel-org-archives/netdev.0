From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Mon, 20 Jun 2011 10:05:37 +1000
Message-ID: <4DFE8ED1.3050007@snapgear.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org> <1308410354-21387-3-git-send-email-shawn.guo@linaro.org> <4DFDDFF4.8000305@snapgear.com> <201106191411.32137.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	Jason Liu <jason.hui@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201106191411.32137.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/06/11 22:11, Arnd Bergmann wrote:
> On Sunday 19 June 2011 13:39:32 Greg Ungerer wrote:
>>> +#ifdef CONFIG_OF
>>> +static const struct of_device_id fec_dt_ids[] = {
>>> +     { .compatible = "fsl,fec", .data =&fec_devtype[0], },
>>> +     {},
>>> +};
>>> +
>>> +static const struct of_device_id *
>>> +fec_get_of_device_id(struct platform_device *pdev)
>>> +{
>>> +     return of_match_device(fec_dt_ids,&pdev->dev);
>>> +}
>>> +#else
>>> +#define fec_dt_ids NULL
>>> +static inline struct of_device_id *
>>> +fec_get_of_device_id(struct platform_device *pdev)
>>> +{
>>> +     return NULL;
>>> +}
>>> +#endif
>>> +
>>>    static unsigned char macaddr[ETH_ALEN];
>>>    module_param_array(macaddr, byte, NULL, 0);
>>>    MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>>> @@ -1363,6 +1385,11 @@ fec_probe(struct platform_device *pdev)
>>>        struct net_device *ndev;
>>>        int i, irq, ret = 0;
>>>        struct resource *r;
>>> +     const struct of_device_id *of_id;
>>> +
>>> +     of_id = fec_get_of_device_id(pdev);
>>
>> fec_get_of_device_id() is defined inside of "#ifdef CONFIG_OF". This
>> use of it will break compilation when this is not defined.
>>
>
>
> Why? Note the #else path defining an empty function.

Sorry, missed that :-)

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
