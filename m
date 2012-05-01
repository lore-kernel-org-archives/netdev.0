From: Ben Greear <greearb@candelatech.com>
Subject: Re: [E1000-devel] e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Tue, 01 May 2012 14:10:43 -0700
Message-ID: <4FA05153.1010903@candelatech.com>
References: <4F909F4B.1010707@candelatech.com> <CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com> <4F91B250.8090509@candelatech.com> <CA+mtBx9s70wawA4E3+LyOQhJXRr1y-0j_Pzno5bBSz8TS3SUOA@mail.gmail.com> <4F91B554.9060902@candelatech.com> <4F91BC82.2000804@intel.com> <CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com> <4F91DB7B.7060601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>
To: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48895 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab2EAVKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 17:10:55 -0400
In-Reply-To: <4F91DB7B.7060601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2012 02:56 PM, Ben Greear wrote:
> On 04/20/2012 02:21 PM, Tom Herbert wrote:
>> Thanks John for pointers to those.  Ben, are you running a kernel with
>> these patches?
>
> I just tested this on my e1000e and igb machine.  With these patches,
> I can no longer reproduce the problem.
>
> So, please make sure those are queued up for 3.3 stable!

Dave:  I think these patches below should go to 3.3 stable.

They are not queued for stable yet as far as I can tell.

Thanks,
Ben

>
> Thanks,
> Ben
>
>>
>> Tom
>>
>>>
>>> Tom, did you see these two patches? Maybe this is resolved by
>>> the second patch.
>>>
>>> We needed these to fixup ixgbe and igb (i didn't test e1000e)
>>> looks like we might want to push these at stable. I don't
>>> believe they are in 3.3.
>>>
>>> commit b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>>> Author: Alexander Duyck<alexander.h.duyck@intel.com>
>>> Date:   Tue Feb 7 02:29:06 2012 +0000
>>>
>>>      net: Add memory barriers to prevent possible race in byte queue limits
>>>
>>>      This change adds a memory barrier to the byte queue limit code to address a
>>>      possible race as has been seen in the past with the
>>>      netif_stop_queue/netif_wake_queue logic.
>>>
>>>      Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>>      Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>>      Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>>
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>>>
>>>
>>> commit 5c4903549c05bbb373479e0ce2992573c120654a
>>> Author: Alexander Duyck<alexander.h.duyck@intel.com>
>>> Date:   Tue Feb 7 02:29:01 2012 +0000
>>>
>>>      net: Fix issue with netdev_tx_reset_queue not resetting queue from XOFF state
>>>
>>>      We are seeing dev_watchdog hangs on several drivers.  I suspect this is due
>>>      to the __QUEUE_STATE_STACK_XOFF bit being set prior to a reset for link
>>>      change, and then not being cleared by netdev_tx_reset_queue.  This change
>>>      corrects that.
>>>
>>>      In addition we were seeing dev_watchdog hangs on igb after running the
>>>      ethtool tests.  We found this to be due to the fact that the ethtool test
>>>      runs the same logic as ndo_start_xmit, but we were never clearing the XOFF
>>>      flag since the loopback test in ethtool does not do byte queue accounting.
>>>
>>>      Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>>      Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>>      Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5c4903549c05bbb373479e0ce2992573c120654a
>>>
>>>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
