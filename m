From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Wed, 02 Nov 2011 19:09:55 -0400 (EDT)
Message-ID: <20111102.190955.1902322759075682192.davem@davemloft.net>
References: <20111102224317.GM31337@atomide.com>
	<4EB1CA4F.3090403@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4EB1CA4F.3090403@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2011 23:55:11 +0100

> There is a problem with your kmalloc() or alignments on your architecture.
> 
> What is the SMP_CACHE_BYTES value ?

kmalloc() behavior doesn't have anything to do with this bug.

The issue is calculation of skb->end, which is based upon calculated
'size' variable.

skb->end determines alignment of skb_shared_info, which is where the
alignment problem is occuring for Tony.

