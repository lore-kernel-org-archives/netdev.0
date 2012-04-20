From: Ben Greear <greearb@candelatech.com>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Fri, 20 Apr 2012 14:56:11 -0700
Message-ID: <4F91DB7B.7060601@candelatech.com>
References: <4F909F4B.1010707@candelatech.com>
	<CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com>
	<4F91B250.8090509@candelatech.com>
	<CA+mtBx9s70wawA4E3+LyOQhJXRr1y-0j_Pzno5bBSz8TS3SUOA@mail.gmail.com>
	<4F91B554.9060902@candelatech.com> <4F91BC82.2000804@intel.com>
	<CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>
To: Tom Herbert <therbert@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 04/20/2012 02:21 PM, Tom Herbert wrote:
> Thanks John for pointers to those.  Ben, are you running a kernel with
> these patches?

I just tested this on my e1000e and igb machine.  With these patches,
I can no longer reproduce the problem.

So, please make sure those are queued up for 3.3 stable!

Thanks,
Ben

>
> Tom
>
>>
>> Tom, did you see these two patches? Maybe this is resolved by
>> the second patch.
>>
>> We needed these to fixup ixgbe and igb (i didn't test e1000e)
>> looks like we might want to push these at stable. I don't
>> believe they are in 3.3.
>>
>> commit b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>> Author: Alexander Duyck<alexander.h.duyck@intel.com>
>> Date:   Tue Feb 7 02:29:06 2012 +0000
>>
>>     net: Add memory barriers to prevent possible race in byte queue limits
>>
>>     This change adds a memory barrier to the byte queue limit code to address a
>>     possible race as has been seen in the past with the
>>     netif_stop_queue/netif_wake_queue logic.
>>
>>     Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>     Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>     Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>>
>>
>> commit 5c4903549c05bbb373479e0ce2992573c120654a
>> Author: Alexander Duyck<alexander.h.duyck@intel.com>
>> Date:   Tue Feb 7 02:29:01 2012 +0000
>>
>>     net: Fix issue with netdev_tx_reset_queue not resetting queue from XOFF state
>>
>>     We are seeing dev_watchdog hangs on several drivers.  I suspect this is due
>>     to the __QUEUE_STATE_STACK_XOFF bit being set prior to a reset for link
>>     change, and then not being cleared by netdev_tx_reset_queue.  This change
>>     corrects that.
>>
>>     In addition we were seeing dev_watchdog hangs on igb after running the
>>     ethtool tests.  We found this to be due to the fact that the ethtool test
>>     runs the same logic as ndo_start_xmit, but we were never clearing the XOFF
>>     flag since the loopback test in ethtool does not do byte queue accounting.
>>
>>     Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>     Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>     Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5c4903549c05bbb373479e0ce2992573c120654a
>>
>>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
