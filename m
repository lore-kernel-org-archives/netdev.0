From: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] of_net.h: Provide dummy functions if OF_NET is not
 configured
Date: Mon, 01 Apr 2013 14:14:10 -0500
Message-ID: <5159DC82.3050804@gmail.com>
References: <1364840349-10696-1-git-send-email-linux@roeck-us.net>
 <5159D588.5070603@gmail.com> <20130401190100.GA1042@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20130401190100.GA1042-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
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

On 04/01/2013 02:01 PM, Guenter Roeck wrote:
> On Mon, Apr 01, 2013 at 01:44:24PM -0500, Rob Herring wrote:
>> On 04/01/2013 01:19 PM, Guenter Roeck wrote:
>>> of_get_mac_address() and of_get_phy_mode() are only provided if OF_NET
>>> is configured. While most callers check for the define, not all do, and those
>>> who do require #ifdef around the code. For those who don't, the missing check
>>> can result in errors such as
>>
>> How about removing the ifdef from those callers?
>>
> That would be the next step, after/if this one is accepted.
> If not, it doesn't make sense to waste my time.

Assuming that is done:

Acked-by: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>

Presumably with the follow-on patches, this can go in thru the net tree.

Rob

> Thanks,
> Guenter
> 
>> Rob
>>
>>>
>>> arch/powerpc/sysdev/tsi108_dev.c:107:3: error: implicit declaration of
>>> 	function 'of_get_mac_address' [-Werror=implicit-function-declaration]
>>> arch/powerpc/sysdev/mv64x60_dev.c:253:2: error: implicit declaration of
>>> 	function 'of_get_mac_address' [-Werror=implicit-function-declaration]
>>>
>>> Provide dummy function declarations if OF_NET is not configured. This is safe
>>> because all callers do check the return values. If desired, at least some of
>>> the #ifdefs in the code can subsequently be removed.
>>>
>>> Cc: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
>>> ---
>>>  include/linux/of_net.h |   10 ++++++++++
>>>  1 file changed, 10 insertions(+)
>>>
>>> diff --git a/include/linux/of_net.h b/include/linux/of_net.h
>>> index f474641..61bf53b 100644
>>> --- a/include/linux/of_net.h
>>> +++ b/include/linux/of_net.h
>>> @@ -11,6 +11,16 @@
>>>  #include <linux/of.h>
>>>  extern const int of_get_phy_mode(struct device_node *np);
>>>  extern const void *of_get_mac_address(struct device_node *np);
>>> +#else
>>> +static inline const int of_get_phy_mode(struct device_node *np)
>>> +{
>>> +	return -ENODEV;
>>> +}
>>> +
>>> +static inline const void *of_get_mac_address(struct device_node *np)
>>> +{
>>> +	return NULL;
>>> +}
>>>  #endif
>>>  
>>>  #endif /* __LINUX_OF_NET_H */
>>>
>>
>>
