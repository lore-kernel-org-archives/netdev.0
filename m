From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Thu, 03 Nov 2011 00:14:12 +0100
Message-ID: <4EB1CEC4.3090909@gmail.com>
References: <20111102224317.GM31337@atomide.com> <4EB1CA4F.3090403@gmail.com> <20111102.190955.1902322759075682192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111102.190955.1902322759075682192.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2011 00:09, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Nov 2011 23:55:11 +0100
> 
>> There is a problem with your kmalloc() or alignments on your architecture.
>>
>> What is the SMP_CACHE_BYTES value ?
> 
> kmalloc() behavior doesn't have anything to do with this bug.
> 
> The issue is calculation of skb->end, which is based upon calculated
> 'size' variable.
> 
> skb->end determines alignment of skb_shared_info, which is where the
> alignment problem is occuring for Tony.
> 


I understood that David, but check the code, and you can see that exact
skb->end depends also on ksize()

So maybe the right fix is to make sure skb->end is properly aligned, say
with SLOB

So a more generic fix is welcomed.
