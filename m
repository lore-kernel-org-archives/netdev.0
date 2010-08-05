From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
 busses
Date: Thu, 05 Aug 2010 09:31:27 -0700
Message-ID: <4C5AE75F.5020507@codeaurora.org>
References: <4C59E654.1090403@codeaurora.org>	<877hk56hiy.fsf@deeprootsystems.com> <4C5A0C68.9080500@codeaurora.org> <87fwytxdba.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com, grant.likely@secretlab.ca, magnus.damm@gmail.com
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <87fwytxdba.fsf@deeprootsystems.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> [snip]
>>>>
>>>> Which will allow the same driver to easily to used on either
>>>> the platform bus or the newly defined bus type.
>>>
>>> Except it requires a re-compile.
>>>
>>> Rather than doing this at compile time, it would be better to support
>>> legacy devices at runtime.  You could handle this by simply registering
>>> the driver on the custom bus and the platform_bus and let the bus
>>> matching code handle it.  Then, the same binary would work on both
>>> legacy and updated SoCs.
>>>
>>
>> Can you safely register a driver on more than one bus? I didn't think
>> that was safe -- normally it's impossible since you're calling
>>
>> struct BUS_TYPE_driver mydriver;
>> BUS_TYPE_driver_register(&mydriver)
>>
>> but now we have multiple "bus types" that are all actually platform type; still,
>> at a minimum you would need:
>> 	struct platform_driver mydrvier1 = {
>> 		.driver.bus = &sub_bus1,
>> 	};
>> 	struct platform_driver mydrvier2 = {
>> 		.driver.bus = &sub_bus2,
>> 	};
>> which would all point to the same driver functions, yet the respective devices
>> attached for the "same" driver would be on different buses. I fear this might
>> confuse some drivers. I don't think dynamic bus assignment is this easy
>>
>> In short: I do not believe the same driver can be registered on multiple
>> different buses -- if this is wrong, please correct me.
> 
> It is possible, and currently done in powerpc land where some
> drivers handle devices on the platform_bus and the custom OF bus.
> 
> However, as noted by Magnus, what we really need here is a way for
> drivers to not care at all what kind of bus they are on.  There are an
> increasing number of drivers that are re-used not just across different
> SoCs in the same family, but across totally different SoCs (e.g. drivers
> for hardware shared between TI OMAP and TI DaVinci, or SH and SH-Mobile/ARM)
> 

I will start trying to work on this

>>>
>>> Up to here, this looks exactly what I wrote in thread referenced
>>> above.
>>>
>>
>> It is, you just went on vacation :)
>>
> 
> Ah, OK.   The changelog was missing credits to that affect, but I was
> more concerned that you hadn't seen my example and didn't want to be
> duplicating work.
> 

will fix.

>>>>  [snip]
> 
>> if you call it second then they will all already be well-defined and
>> thus not overwritten.
> 
> Right, they will not be overwritten, but you'll be left with a mostly
> empty dev_pm_ops on the custom bus.
> 
> IOW, Most of these custom busses will only want to customize a small
> subset of the dev_pm_ops methods (e.g. only the runtime PM methods.)  If
> you setup your sparsly populated custom dev_pm_ops and then call
> platform_bus_type_init() second, dev_pm_ops on the new buswill have *only*
> your custom fields, and none of the defaults from platform_dev_pm_ops.
> 
> So, what I was getting at is that it should probably be clearer to the
> users of platform_bus_type_init() that any customization of dev_pm_ops
> should be done after.
> 

I understand what you're saying now, and I can fix this as well.

> 
>>
>> If you would like to lead this effort, please do so; I did not mean to step
>> on your toes, it's just that this is an issue for me as well. 
> 
> No worries there, my toes are fine.   :) 

Good :)

> 
>> You had indicated that you were going on vacation for a month and I
>> had not seen any more follow-up on this issue, so I forged ahead.
> 
> Great, I'm glad you forged ahead.  There is definitely a broader need
> for something like this, and I have no personal attachment to the code.
> 
> I have no problems with you continuing the work (in fact, I'd prefer it.
> I have lots of other things to catch up on after my vacation.)
> 
> In the future though, it's common (and kind) to note the original author
> in the changelog when basing a patch on previous work.  Something like
> "originally written by..."  or "based on the work of..." etc.

Ok, I can do that; that was the intention of the "original inspiration from"
line at the beginning.  Is there a more formal way of indicating this in the
next version of the patch? Should I add you as a "From:" or an "Author:"?

-Pat


-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
