From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: removing bridge in vlan_filtering mode requests delete of
 attached ports main MAC address
Date: Wed, 1 Nov 2017 09:58:01 +0900
Message-ID: <d1674dbe-a20d-bc08-3008-ffe312d84273@lab.ntt.co.jp>
References: <02874ECE860811409154E81DA85FBB5882ACC9A4@ORSMSX115.amr.corp.intel.com>
 <e48172b8-52ec-a9e8-c720-d9da69d8ced7@redhat.com>
 <02874ECE860811409154E81DA85FBB5882AD0E1A@ORSMSX115.amr.corp.intel.com>
 <02874ECE860811409154E81DA85FBB5882AD0E46@ORSMSX115.amr.corp.intel.com>
 <02874ECE860811409154E81DA85FBB5882AD8CF4@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Malek, Patryk" <patryk.malek@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "vyasevic@redhat.com" <vyasevic@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:53225 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbdKAA6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 20:58:23 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5882AD8CF4@ORSMSX115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/11/01 9:10, Keller, Jacob E wrote:
>> -----Original Message-----
>> From: Keller, Jacob E
>> Sent: Thursday, October 26, 2017 1:33 PM
>> To: Keller, Jacob E <jacob.e.keller@intel.com>; vyasevic@redhat.com;
>> netdev@vger.kernel.org
>> Cc: Malek, Patryk <patryk.malek@intel.com>
>> Subject: RE: removing bridge in vlan_filtering mode requests delete of attached
>> ports main MAC address
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org]
>>> On Behalf Of Keller, Jacob E
>>> Sent: Thursday, October 26, 2017 1:27 PM
>>> To: vyasevic@redhat.com; netdev@vger.kernel.org
>>> Cc: Malek, Patryk <patryk.malek@intel.com>
>>> Subject: RE: removing bridge in vlan_filtering mode requests delete of attached
>>> ports main MAC address
>>>
>>>> -----Original Message-----
>>>> From: Vlad Yasevich [mailto:vyasevic@redhat.com]
>>>> Sent: Thursday, October 26, 2017 3:22 AM
>>>> To: Keller, Jacob E <jacob.e.keller@intel.com>; netdev@vger.kernel.org
>>>> Cc: Malek, Patryk <patryk.malek@intel.com>
>>>> Subject: Re: removing bridge in vlan_filtering mode requests delete of
>> attached
>>>> ports main MAC address
>>>>
>>>> Hi Jake
>>>>
>>>> I think adding a !fdb->local should work.  local fdb contain the address of
>>> assigned
>>>> to
>>>> the ports of the bridge and those shouldn't be directly removed.
>>>>
>>>> If that works,  that looks like the right solution.
>>>>
>>>> -vlad
>>>>
>>>
>>> So this does prevent us from removing the port's address. However, if I add
>> two
>>> devices to the bridge, then after removing the bridge, each device now keeps
>>> both permanent addresses in their list, which isn't what we want is it?
>>>
>>> Do we even want to assign the local fdb addresses to every port?
>>>
>>> Obviously, I don't fully understand this code, so I think I'm missing something
>>> here.
>>>
>>> Regards,
>>> Jake
>>>
>>
>> Ok, I tried this again, and it didn't end up crossing the local device addresses to
>> each port. I'm not sure how that happened the first time yet, so maybe it is
>> correct to skip removing local addresses... but if we skip removing them, wouldn't
>> we want to skip adding them too?
>>
>> Thanks,
>> Jake
> 
> There's definitely some weirdness going on, because I've been able to get the local port addresses added to the wrong device under some circumstances. It seems to be some sort of race condition, since I can't reliably re-create the scenario.
> 
> Either way, some more insight on what the correct fix here would be nice.
> 
> I'm thinking we want to skip adding or removing local addresses when switching into the static mode configuration.

If we skip adding them, we cannot receive frames which should be
received on the bridge device during non-promiscuous mode.

-- 
Toshiaki Makita
