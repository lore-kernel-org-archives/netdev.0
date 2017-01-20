From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Fri, 20 Jan 2017 13:44:37 +0200
Message-ID: <87y3y6lzve.fsf@kamboji.qca.qualcomm.com>
References: <20170119141508.GA6245@tuxdriver.com>
        <20170119155620.GD6245@tuxdriver.com>
        <87h94uorc1.fsf@kamboji.qca.qualcomm.com>
        <20170119.142230.1012416564568457058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, darcari@redhat.com, netdev@vger.kernel.org,
        johannes.berg@intel.com, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44940 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdATLoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 06:44:44 -0500
In-Reply-To: <20170119.142230.1012416564568457058.davem@davemloft.net> (David
        Miller's message of "Thu, 19 Jan 2017 14:22:30 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Thu, 19 Jan 2017 20:08:30 +0200
>
>> "John W. Linville" <linville@tuxdriver.com> writes:
>> 
>>> I forgot to Cc Johannes and Kalle...
>> 
>> Also adding linux-wireless.
>> 
>>> On Thu, Jan 19, 2017 at 09:15:09AM -0500, John W. Linville wrote:
>>>
>>>> I'm responsible for this mess. The original idea was for various
>>>> mac80211-based drivers to override the ethtool operation and provide
>>>> their own dump operation, but the mac80211 crowd never embraced
>>>> the idea.
>>>> 
>>>> In the meantime, I added the default implementation which just
>>>> passed-up wdev->wiphy->hw_version as the version info for a 0-length
>>>> register dump. I then implemented a driver-specific regiser dump
>>>> handler for userland ethtool that would interpret the hardware version
>>>> information for the at76c50x-usb driver.
>>>> 
>>>> So the net of it is, if we treat a return of 0 from get_regs_len()
>>>> as "not supported", we break this one driver-specific feature for
>>>> userland ethtool. Realistically, there are probably very few users
>>>> to care. But I can't guarantee that the number is zero.
>> 
>> I know the number is not zero, because I remember using it years back
>> with something else than at76c50x-usb. But is the number more than one,
>> I don't know :)
>
> I'm trying to dig down and figure out why this problem is showing up now.
> ethtool_get_regs() has been using vzalloc() since 2011, and before that it
> used plain vmalloc().
>
> This code has therefore been using v{m,z}alloc() forever.  What changed?
>
> The zero size check has been in the vmalloc implementation since at least
> 2009.
>
> I don't understand why this is all triggering and being noticed now.  The
> whole ieee80211 "return zero length regs and return hw version in get_regs"
> thing should have been failing for at least 7 years now.

Maybe just nobody hasn't used it since? If my memory serves me right
(too often it does not) It's 6-7 years since I used this, and if the
kernel I worked on at the time was a year or two old, I might have used
a version without the zero size check.

But I'm just hand-waving here, I cannot be sure what's the last kernel I
used.

-- 
Kalle Valo
