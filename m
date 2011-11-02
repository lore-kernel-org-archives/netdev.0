From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Wed, 02 Nov 2011 19:17:16 -0400 (EDT)
Message-ID: <20111102.191716.1682282796914825621.davem@davemloft.net>
References: <4EB1CA4F.3090403@gmail.com>
	<20111102.190955.1902322759075682192.davem@davemloft.net>
	<4EB1CEC4.3090909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EB1CEC4.3090909@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

c> 
> The issue is calculation of skb->end, which is based upon calculated
> 'size' variable.
> 
> skb->end determines alignment of skb_shared_info, which is where the
> alignment problem is occuring for Tony.

Right, and SMP_CACHE_BYTES setting should save us in any case.

For ARM, SMP_CACHE_BYTES seems to be set to L1_CACHE_BYTES which in
turn is set via ARM_L1_CACHE_SHIFT which can be set seemingly to any
value but the defaults are 5 and 6 which should be OK.

So unless Tony is using a non-standard setting of ARM_L1_CACHE_SHIFT,
this report is a bit mysterious.
