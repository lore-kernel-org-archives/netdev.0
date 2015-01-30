From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 0/7] switchdev offload flags
Date: Fri, 30 Jan 2015 11:49:07 -0800
Message-ID: <54CBE033.4010501@cumulusnetworks.com>
References: <1422600017-42393-1-git-send-email-roopa@cumulusnetworks.com> <20150130165940.GA1872@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:43773 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbA3TtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 14:49:09 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so55968188pab.3
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 11:49:08 -0800 (PST)
In-Reply-To: <20150130165940.GA1872@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/15, 8:59 AM, Jiri Pirko wrote:
> Fri, Jan 30, 2015 at 07:40:10AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch series introduces new offload flags for switchdev.
>> Kernel network subsystems can use this flag to accelerate
>> network functions by offloading to hw.
>>
>> I expect that there will be need for subsystem specific feature
>> flag in the future.
>>
>> This patch series currently only addresses bridge driver link
>> attribute offloads to hardware.
>>
>> Looking at the current state of bridge l2 offload in the kernel,
>>     - flag 'self' is the way to directly manage the bridge device in hw via
>>       the ndo_bridge_setlink/ndo_bridge_getlink calls
>>
>>     - flag 'master' is always used to manage the in kernel bridge devices
>>       via the same ndo_bridge_setlink/ndo_bridge_getlink calls
>>
>> Today these are used separately. The nic offloads use hwmode "vepa/veb" to go
>> directly to hw with the "self" flag.
>>
>> At this point i am trying not to introduce any new user facing flags/attributes.
>> In the model where we want the kernel bridging to be accelerated with
>> hardware, we very much want the bridge driver to be involved.
>>
>> In this proposal,
>> - The offload flag/bit helps switch asic drivers to indicate that they
>>   accelerate the kernel networking objects/functions
>> - The user does not have to specify a new flag to do so. A bridge created with
>>   switch asic ports will be accelerated if the switch driver supports it.
>> - The user can continue to directly manage l2 in nics (ixgbe) using the
>>   existing hwmode/self flags
>> - It also does not stop users from using the 'self' flag to talk to the
>>   switch asic driver directly
>> - Involving the bridge driver makes sure the add/del notifications to user
>>   space go out after both kernel and hardware are programmed
>>
>> (To selectively offload bridge port attributes,
>> example learning in hw only etc, we can introduce offload bits for
>> per bridge port flag attribute as in my previous patch
>> https://patchwork.ozlabs.org/patch/413211/. I have not included that in this
>> series)
>>
>> v2
>>    - try a different name for the offload flag/bit
>>    - tries to solve the stacked netdev case by traversing the lowerdev
>>      list to reach the switch port
>>
>> v3 -
>>     - Tested with bond as bridge port for the stacked device case.
>>       Includes a bond_fix_features change to not ignore the
>>       NETIF_F_HW_NETFUNC_OFFLOAD flag
>>     - Some checkpatch fixes
>>
>> v4 -
>>     - rename flag to NETIF_F_HW_SWITCH_OFFLOAD
>>     - add ndo_bridge_setlink/dellink handlers in bond and team drivers as
>>       suggested by jiri.
>>     - introduce default ndo_dflt_netdev_switch_port_bridge_setlink/dellink
>>     handlers that masters can use to call offload api on lowerdevs.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Having a flu and being completely unusable, I gave this patchset a quick
> peek and looks allright. I will review once I recover (Sun/Mon).
> Not sure if Dave wants to hold the patchset until then.
>
>
ok sounds good,  thanks, hope you feel better soon.
