From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH v3 1/6] net: cpsw: enhance pinctrl support
Date: Thu, 30 May 2013 13:38:23 +0530
Message-ID: <51A708F7.8010804@ti.com>
References: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
 <1369592616-23972-2-git-send-email-mugunthanvnm@ti.com>
 <20130527213600.GO13507@atomide.com> <51A4B995.9050203@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>, benoit.cousson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <51A4B995.9050203-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 5/28/2013 7:35 PM, Mugunthan V N wrote:
> On 5/28/2013 3:06 AM, Tony Lindgren wrote:
>> * Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> [130526 11:28]:
>>> From: Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>
>>>
>>> Amend cpsw controller to optionally take a pin control handle and set
>>> the state of the pins to:
>>>
>>> - "default" on boot, resume
>>> - "sleep" on suspend()
>>>
>>> This should make it possible to optimize energy usage for the pins
>>> for the suspend/resume cycle.
>>>
>>> If any of the above pin states are missing in dt, a warning message
>>> about the missing state is displayed.
>>> If certain pin-states are not available, to remove this warning message
>>> pass respective state name with null phandler.
>>>
>>> Signed-off-by: Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>
>>> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>>> ---
>>>   drivers/net/ethernet/ti/cpsw.c |   48 
>>> ++++++++++++++++++++++++++++++++++++++++
>>>   1 file changed, 48 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/ti/cpsw.c 
>>> b/drivers/net/ethernet/ti/cpsw.c
>>> index 21a5b29..c9ed730 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -35,6 +35,7 @@
>>>   #include <linux/if_vlan.h>
>>>     #include <linux/platform_data/cpsw.h>
>>> +#include <linux/pinctrl/consumer.h>
>>>     #include "cpsw_ale.h"
>>>   #include "cpts.h"
>>> @@ -351,6 +352,11 @@ struct cpsw_priv {
>>>       bool irq_enabled;
>>>       struct cpts *cpts;
>>>       u32 emac_port;
>>> +
>>> +    /* Two optional pin states - default & sleep */
>>> +    struct pinctrl        *pinctrl;
>>> +    struct pinctrl_state    *pins_def;
>>> +    struct pinctrl_state    *pins_sleep;
>>>   };
>> Which pins do you need to dynamically remux? If it's not all
>> the pins, you should have three sets: default, active and idle.
>> This way the static pins in the default group don't need to be
>> constantly toggled.
>>
>> Regards,
>>
>> Tony
> Tony
>
> I am using this for all the pins, in probe all the cpsw pins will be 
> configured
> and i have used the same in suspend/resume callback for power saving.
>
Tony

Do you have any comments on this, or is it ok with two pinctrl_state nodes?

Regards
Mugunthan V N
