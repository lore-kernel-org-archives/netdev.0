From: "Yan, Zheng" <zheng.z.yan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 09:55:54 +0800
Message-ID: <4F0A492A.5080504@intel.com>
References: <4F065F59.2070107@intel.com>  <1325843269.3330.4.camel@jlt3.sipsolutions.net>  <4F0A3C62.6010403@intel.com> <1326069251.13074.360.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1326069251.13074.360.camel@wwguy-huron>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/09/2012 08:34 AM, Guy, Wey-Yi wrote:
> On Mon, 2012-01-09 at 09:01 +0800, Yan, Zheng wrote:
>> On 01/06/2012 05:47 PM, Johannes Berg wrote:
>>> [add linux-wireless]
>>>
>>> On Fri, 2012-01-06 at 10:41 +0800, Yan, Zheng wrote:
>>>> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
>>>> Namely, make the driver suspend the device after shutting down the interface and
>>>> resume the device when activating the interface. In my test, suspending the device
>>>> can save about 0.4 watt power. The shortcoming is that the device no longer generate
>>>> rfkill changes interrupt.
>>>
>>> NACK due to that last sentence. There's no way we can live with that in
>>> the general case -- and your patch isn't even configurable afaict. And
>>> I'm sure polling the rfkill flag would use just as much energy.
>>>
>> It's configurable, runtime PM is disabled by default.
> 
> Somehow I miss it, how you configure it?
> 
change the value of /sys/devices/.../power/control to auto to enable the runtime PM.
(e.g echo auto > /sys/devices/pci0000:00/0000:00:1c.3/0000:02:00.0/power/control)

>>
>>> There might be some value in this in a system that doesn't have a hard
>>> rfkill line, but that means this needs to be configurable since the
>>> device can't know whether there's a button or not [1].
>>>
>> The patch targets system that only use software rfkill
> 
> How you control that?  
I can't. Our team is working on runtime PM project, the purpose of the patch is
more or less to demonstrate how much power can be saved.

Regards
Yan, Zheng

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
