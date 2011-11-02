From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Wed, 02 Nov 2011 19:22:14 -0400 (EDT)
Message-ID: <20111102.192214.167538247245013824.davem@davemloft.net>
References: <4EB1CEC4.3090909@gmail.com>
	<20111102.191716.1682282796914825621.davem@davemloft.net>
	<20111102231917.GN31337@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: tony@atomide.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111102231917.GN31337@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Lindgren <tony@atomide.com>
Date: Wed, 2 Nov 2011 16:19:17 -0700

> * David Miller <davem@davemloft.net> [111102 15:42]:
>> c> 
>> > The issue is calculation of skb->end, which is based upon calculated
>> > 'size' variable.
>> > 
>> > skb->end determines alignment of skb_shared_info, which is where the
>> > alignment problem is occuring for Tony.
>> 
>> Right, and SMP_CACHE_BYTES setting should save us in any case.
>> 
>> For ARM, SMP_CACHE_BYTES seems to be set to L1_CACHE_BYTES which in
>> turn is set via ARM_L1_CACHE_SHIFT which can be set seemingly to any
>> value but the defaults are 5 and 6 which should be OK.
>> 
>> So unless Tony is using a non-standard setting of ARM_L1_CACHE_SHIFT,
>> this report is a bit mysterious.
> 
> This is happening at least with omap1_defconfig. In that case we have
> ARM_L1_CACHE_SHIFT=5.

Ok, so ksize(x) gives an odd value for whichever allocator you are
using.  Which is the point Eric was trying to make.  It becomes
clearernow.
