From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 1/5] tg3: Convert to use
 hwmon_device_register_with_groups
Date: Tue, 26 Nov 2013 09:50:30 -0800
Message-ID: <5294DF66.3080801@broadcom.com>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
 <1385186881-7931-2-git-send-email-linux@roeck-us.net>
 <5293FEFA.4000700@broadcom.com> <52940BD4.9000605@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>,
	"Bruce Allan" <bruce.w.allan@intel.com>,
	"Carolyn Wyborny" <carolyn.wyborny@intel.com>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"Michael Chan" <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org
To: "Guenter Roeck" <linux@roeck-us.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4822 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022Ab3KZRuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 12:50:52 -0500
In-Reply-To: <52940BD4.9000605@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/25/2013 06:47 PM, Guenter Roeck wrote:
> On 11/25/2013 05:52 PM, Nithin Nayak Sujir wrote:
>>
>>
>> On 11/22/2013 10:07 PM, Guenter Roeck wrote:
>>> Use new hwmon API to simplify code, provide missing mandatory 'name'
>>> sysfs attribute, and attach hwmon attributes to hwmon device instead
>>> of pci device.
>>>
>>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>>> ---
>>>   drivers/net/ethernet/broadcom/tg3.c |   25 ++++++-------------------
>>>   1 file changed, 6 insertions(+), 19 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/broadcom/tg3.c
>>> b/drivers/net/ethernet/broadcom/tg3.c
>>> index a9e0684..369b736 100644
>>> --- a/drivers/net/ethernet/broadcom/tg3.c
>>> +++ b/drivers/net/ethernet/broadcom/tg3.c
>>> @@ -10629,10 +10629,8 @@ static void tg3_sd_scan_scratchpad(struct tg3 *tp,
>>> struct tg3_ocir *ocir)
>>>   static ssize_t tg3_show_temp(struct device *dev,
>>>                    struct device_attribute *devattr, char *buf)
>>>   {
>>> -    struct pci_dev *pdev = to_pci_dev(dev);
>>> -    struct net_device *netdev = pci_get_drvdata(pdev);
>>> -    struct tg3 *tp = netdev_priv(netdev);
>>>       struct sensor_device_attribute *attr = to_sensor_dev_attr(devattr);
>>> +    struct tg3 *tp = dev_get_drvdata(dev);
>>
>>
>> Shouldn't this be
>> struct tg3 *tp = netdev_priv(dev_get_drvdata(dev));
>>
>
> 'struct tg3 *tp' is attached to the hwmon device in
> hwmon_device_register_with_groups(), so it can be retrieved
> with dev_get_drvdata() from there. Keep in mind that 'dev'
> is no longer the pci device but the hwmon device.
>

Ah, I see.

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>


> Guenter
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
