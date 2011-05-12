From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_packet: Don't initialize vnet_hdr
Date: Thu, 12 May 2011 17:36:08 -0400 (EDT)
Message-ID: <20110512.173608.1652572492952866283.davem@davemloft.net>
References: <18a010357eb63dfd50751c5eb529f6261cf90ecd.1305232529.git.joe@perches.com>
	<20110512.172623.220889608152651989.davem@davemloft.net>
	<1305236000.6124.67.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305236000.6124.67.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 12 May 2011 14:33:20 -0700

> On Thu, 2011-05-12 at 17:26 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Thu, 12 May 2011 13:36:10 -0700
>> 
>> > Save a memset, initialize only the portion necessary.
>> > 
>> > packet_snd either gets this structure completely from
>> > memcpy_fromiovec or uses only the hdr_len set to 0,
>> > so don't always initialize the structure to 0.
>> > 
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> 
>> On ARM this won't be tightly packed, therefore you'll leave
>> uninitialized pieces of padding in this structure and this
>> thing is an "on-the-wire" network header.
>> 
>> I'm not applying this.
> 
> I believe that it's only sent when po->has_vnet_hdr
> is set.  In that case, it's completely filled from
> memcpy_fromiovec.  In the not set po->has_vnet_hdr case,
> only vnet_hdr.hdr_len is accessed by packet_alloc_skb.

I think with the way this code is protecting accesses to vnet_hdr,
it's going to start warning that some parts "may" be use
uninitialized.

It's also slightly ugly to partially initialize these on-stack things.

I would rather see the code rearranged such that this sort of
hackish scheme isn't necessary.

Again, I'm not applying this.
