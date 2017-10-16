From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ethtool question
Date: Mon, 16 Oct 2017 11:10:16 -0700
Message-ID: <fec121f7-67bb-486f-ffc0-59f292614043@candelatech.com>
References: <492e57b2-ac0a-ff01-2698-e048e97d8e37@candelatech.com>
 <20171011204406.GC30940@tuxdriver.com>
 <20171011.134919.321292333200236097.davem@davemloft.net>
 <59DFE275.3050805@candelatech.com>
 <CAJieiUhsxPRPBBV1WJR6NRfzDKt-8c=QYRHhwoW33KchSb-gXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54176 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754365AbdJPSKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 14:10:19 -0400
In-Reply-To: <CAJieiUhsxPRPBBV1WJR6NRfzDKt-8c=QYRHhwoW33KchSb-gXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 03:00 PM, Roopa Prabhu wrote:
> On Thu, Oct 12, 2017 at 2:45 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 10/11/2017 01:49 PM, David Miller wrote:
>>>
>>> From: "John W. Linville" <linville@tuxdriver.com>
>>> Date: Wed, 11 Oct 2017 16:44:07 -0400
>>>
>>>> On Wed, Oct 11, 2017 at 09:51:56AM -0700, Ben Greear wrote:
>>>>>
>>>>> I noticed today that setting some ethtool settings to the same value
>>>>> returns an error code.  I would think this should silently return
>>>>> success instead?  Makes it easier to call it from scripts this way:
>>>>>
>>>>> [root@lf0313-6477 lanforge]# ethtool -L eth3 combined 1
>>>>> combined unmodified, ignoring
>>>>> no channel parameters changed, aborting
>>>>> current values: tx 0 rx 0 other 1 combined 1
>>>>> [root@lf0313-6477 lanforge]# echo $?
>>>>> 1
>>>>
>>>>
>>>> I just had this discussion a couple of months ago with someone. My
>>>> initial feeling was like you, a no-op is not a failure. But someone
>>>> convinced me otherwise...I will now endeavour to remember who that
>>>> was and how they convinced me...
>>>>
>>>> Anyone else have input here?
>>>
>>>
>>> I guess this usually happens when drivers don't support changing the
>>> settings at all.  So they just make their ethtool operation for the
>>> 'set' always return an error.
>>>
>>> We could have a generic ethtool helper that does "get" and then if the
>>> "set" request is identical just return zero.
>>>
>>> But from another perspective, the error returned from the "set" in this
>>> situation also indicates to the user that the driver does not support
>>> the "set" operation which has value and meaning in and of itself.  And
>>> we'd lose that with the given suggestion.
>>
>>
>> In my case, the driver (igb) does support the set, my program just made the
>> same
>> ethtool call several times and it fails after the initial change (that
>> actually
>> changes something), as best as I can figure.
>
>
> This error is returned by ethtool user-space. It does a get, check and
> then set if user has requested changes.
>

So, should we fix ethtool to return 0 in this case instead of an error code?

I think so.  If the driver itself returns an error, then probably return the
error code and/or fix the driver as seems appropriate.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
