From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 17:04:43 +0800
Message-ID: <4F0AADAB.4070608@intel.com>
References: <4F065F59.2070107@intel.com>  <1325843269.3330.4.camel@jlt3.sipsolutions.net>  <4F0A3C62.6010403@intel.com> <1326069251.13074.360.camel@wwguy-huron>  <4F0A492A.5080504@intel.com> <1326071127.13074.367.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, ilw@linux.intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972Ab2AIJEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 04:04:45 -0500
In-Reply-To: <1326071127.13074.367.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2012 09:05 AM, Guy, Wey-Yi wrote:
> On Mon, 2012-01-09 at 09:55 +0800, Yan, Zheng wrote:
>> On 01/09/2012 08:34 AM, Guy, Wey-Yi wrote:
>>> On Mon, 2012-01-09 at 09:01 +0800, Yan, Zheng wrote:
>>>> On 01/06/2012 05:47 PM, Johannes Berg wrote:
>>>>> [add linux-wireless]
>>>>>
>>>>> On Fri, 2012-01-06 at 10:41 +0800, Yan, Zheng wrote:
>>>>>> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
>>>>>> Namely, make the driver suspend the device after shutting down the interface and
>>>>>> resume the device when activating the interface. In my test, suspending the device
>>>>>> can save about 0.4 watt power. The shortcoming is that the device no longer generate
>>>>>> rfkill changes interrupt.
>>>>>
>>>>> NACK due to that last sentence. There's no way we can live with that in
>>>>> the general case -- and your patch isn't even configurable afaict. And
>>>>> I'm sure polling the rfkill flag would use just as much energy.
>>>>>
>>>> It's configurable, runtime PM is disabled by default.
>>>
>>> Somehow I miss it, how you configure it?
>>>
>> change the value of /sys/devices/.../power/control to auto to enable the runtime PM.
>> (e.g echo auto > /sys/devices/pci0000:00/0000:00:1c.3/0000:02:00.0/power/control)
> 
> I am not sure it is acceptable, how you expect user figure out the pci
> space especially the NIC can be in any of the PCI slots.
> 
>>
>>>>
>>>>> There might be some value in this in a system that doesn't have a hard
>>>>> rfkill line, but that means this needs to be configurable since the
>>>>> device can't know whether there's a button or not [1].
>>>>>
>>>> The patch targets system that only use software rfkill
>>>
>>> How you control that?  
>> I can't. Our team is working on runtime PM project, the purpose of the patch is
>> more or less to demonstrate how much power can be saved.
>>
> I understand, but unless we figure out either make rkill interrupt works
> in runtime PM, or figure out the platform does not has HW RFKILL
> automatically, I don't see how this patch can upstream without generate
> a lot of issues and bug reports.
> 
Thank you for the suggestion.

Yan, Zheng
