From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH v3 1/6] net: cpsw: enhance pinctrl support
Date: Wed, 5 Jun 2013 22:13:03 +0530
Message-ID: <51AF6A97.5060407@ti.com>
References: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com> <1369592616-23972-2-git-send-email-mugunthanvnm@ti.com> <20130527213600.GO13507@atomide.com> <51A4B995.9050203@ti.com> <51A708F7.8010804@ti.com> <20130605154921.GW3331@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tony Lindgren <tony@atomide.com>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Hebbar Gururaja <gururaja.hebbar@ti.com>,
	<benoit.cousson@linaro.org>, <linux-omap@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:54012 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657Ab3FEQpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 12:45:00 -0400
In-Reply-To: <20130605154921.GW3331@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/2013 9:19 PM, Tony Lindgren wrote:
> * Mugunthan V N <mugunthanvnm@ti.com> [130530 01:14]:
>> On 5/28/2013 7:35 PM, Mugunthan V N wrote:
>>> On 5/28/2013 3:06 AM, Tony Lindgren wrote:
>>>> * Mugunthan V N <mugunthanvnm@ti.com> [130526 11:28]:
>>>>> From: Hebbar Gururaja <gururaja.hebbar@ti.com>
>>>>>
>>>>> Amend cpsw controller to optionally take a pin control handle and set
>>>>> the state of the pins to:
>>>>>
>>>>> - "default" on boot, resume
>>>>> - "sleep" on suspend()
>>>>>
>>>>> This should make it possible to optimize energy usage for the pins
>>>>> for the suspend/resume cycle.
>>>>>
>>>>> If any of the above pin states are missing in dt, a warning message
>>>>> about the missing state is displayed.
>>>>> If certain pin-states are not available, to remove this warning message
>>>>> pass respective state name with null phandler.
>>>>>
>>>>> Signed-off-by: Hebbar Gururaja <gururaja.hebbar@ti.com>
>>>>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>>>>> ---
>>>>>   drivers/net/ethernet/ti/cpsw.c |   48
>>>>> ++++++++++++++++++++++++++++++++++++++++
>>>>>   1 file changed, 48 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>>>> b/drivers/net/ethernet/ti/cpsw.c
>>>>> index 21a5b29..c9ed730 100644
>>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>>> @@ -35,6 +35,7 @@
>>>>>   #include <linux/if_vlan.h>
>>>>>     #include <linux/platform_data/cpsw.h>
>>>>> +#include <linux/pinctrl/consumer.h>
>>>>>     #include "cpsw_ale.h"
>>>>>   #include "cpts.h"
>>>>> @@ -351,6 +352,11 @@ struct cpsw_priv {
>>>>>       bool irq_enabled;
>>>>>       struct cpts *cpts;
>>>>>       u32 emac_port;
>>>>> +
>>>>> +    /* Two optional pin states - default & sleep */
>>>>> +    struct pinctrl        *pinctrl;
>>>>> +    struct pinctrl_state    *pins_def;
>>>>> +    struct pinctrl_state    *pins_sleep;
>>>>>   };
>>>> Which pins do you need to dynamically remux? If it's not all
>>>> the pins, you should have three sets: default, active and idle.
>>>> This way the static pins in the default group don't need to be
>>>> constantly toggled.
>>>>
>>>> Regards,
>>>>
>>>> Tony
>>> Tony
>>>
>>> I am using this for all the pins, in probe all the cpsw pins will
>>> be configured
>>> and i have used the same in suspend/resume callback for power saving.
>>>
>> Tony
>>
>> Do you have any comments on this, or is it ok with two pinctrl_state nodes?
> If you always need to remux all the pins, then yes that's fine with me.
>
> Regards,
>
> Tony
David

As Tony accepted the implementation, I will resend the patch series as one
of the patch (pasted below) in this series is already merged in net-next.

f6655d6  Mugunthan V N   ARM: dts: AM33XX: Add CPSW phy_id device tree 
data to am335x-evmsk Mon Jun 3 20:10:09 2013 +0000

Regards
Mugunthan V N
