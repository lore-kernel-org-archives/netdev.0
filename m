From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: Fix Kconfig for some corner cases
Date: Mon, 08 Jul 2013 21:33:15 -0500
Message-ID: <51DB766B.5010304@lwfinger.net>
References: <1373165244-9536-1-git-send-email-Larry.Finger@lwfinger.net>  <1373190151.3428.13.camel@deadeye.wl.decadent.org.uk>  <51D9AFB2.2030707@lwfinger.net> <1373330415.1860.14.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:61054 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab3GICdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 22:33:18 -0400
In-Reply-To: <1373330415.1860.14.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2013 07:40 PM, Ben Hutchings wrote:
> On Sun, 2013-07-07 at 13:13 -0500, Larry Finger wrote:
>> On 07/07/2013 04:42 AM, Ben Hutchings wrote:
>>> On Sat, 2013-07-06 at 21:47 -0500, Larry Finger wrote:
>>>>
>>>> Although I could not duplicate this result on my machine, it seemed likely
>>>> that it was due to the unusual configuration where rtlwifi was being built,
>>>> but none of its dependent drivers were selected.
>>>
>>> I think it just requires:
>>>
>>> CONFIG_USB=m
>>> CONFIG_RTLWIFI=y
>>>
>>>> The fix is to select rtlwifi only when it is needed.
>>>
>>> I don't think so.  Consider this configuration:
>>>
>>> CONFIG_PCI=y
>>> CONFIG_USB=m
>>> CONFIG_RTL_CARDS=y
>>> CONFIG_RTL8192CE=y
>>> CONFIG_RTL8192CU=m
>>> CONFIG_RTLWIFI=y     # maximum of RTL8192CE=y and RTL8192CU=m
>>>
>>> The same breakage occurs.
>>
>> Ben,
>>
>> Thanks for your comments. I certainly do not claim to understand very much about
>> the whole Kbuild process.
>>
>> After setting up the above configuration manually, I ran 'make oldconfig' and
>> got back
>>
>> CONFIG_RTL_CARDS=m
>> CONFIG_RTL8192CE=m
>> CONFIG_RTL8192SE=m
>> CONFIG_RTL8192DE=m
>> CONFIG_RTL8723AE=m
>> CONFIG_RTL8188EE=m
>> CONFIG_RTL8192CU=m
>> CONFIG_RTLWIFI=m
>> CONFIG_RTLWIFI_DEBUG=y
>> CONFIG_RTL8192C_COMMON=m
>>
>> That set of configuration parameters built normally.
>
> But you can still manually set:
>
> CONFIG_PCI=y
> CONFIG_USB=m
> CONFIG_MAC80211=y   # maybe you had =m here?
> CONFIG_RTL_CARDS=y
> CONFIG_RTL8192CE=y
>
> and that will select:
>
> CONFIG_RTLWIFI=y
>
>>>> While making this
>>>> change, I simplified the configuration so that variable RTLWIFI is never seen
>>>> by the user.
>>> [...]
>>>
>>> This will break existing configurations as RTL_CARDS defaults to n.
>>
>> I added a 'default y' to the RTL_CARDS stanza. I now get the following:
>>
>> finger@larrylap:~/staging> make
>> scripts/kconfig/conf --silentoldconfig Kconfig
>> *
>> * Restart config...
>> *
>> *
>> * Realtek rtlwifi family of devices
>> *
>> Realtek rtlwifi family of devices (RTL_CARDS) [M/n/?] (NEW)
>>
>> That should prevent breakage of existing configurations. It defaults to "m"
>> because mac80211 is built as a module in my configuration.
>>
>>> Perhaps you should introduce separate modules for the common PCI and USB
>>> support code, similarly to how the rt2x00 modules are organised.
>>
>> That would not be very difficult, but it would involve converting the single
>> module rtlwifi into 3 separate entities. Does that make sense to you? I'm not sure.
>
> Yes it does make sense.

I will be submitting a new patch as an RFC.

Larry
