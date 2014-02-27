From: David Miller <davem@davemloft.net>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 16:58:01 -0500 (EST)
Message-ID: <20140227.165801.2026085171656485226.davem@davemloft.net>
References: <20140227154635.GA24226@mtl-eit-vdi-22.mtl.labs.mlnx>
	<20140227.153601.1100017228027738567.davem@davemloft.net>
	<20140227214752.GA2678@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaB0V6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:58:04 -0500
In-Reply-To: <20140227214752.GA2678@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 27 Feb 2014 23:47:54 +0200

> On 27/02/14 15:36 -0500, David Miller wrote:
>> From: Amir Vadai <amirv@mellanox.com>
>> Date: Thu, 27 Feb 2014 17:46:37 +0200
>> 
>> > On 27/02/14 06:44 -0800, Eric Dumazet wrote:
>> >> On Thu, 2014-02-27 at 16:02 +0200, Amir Vadai wrote:
>> >> >  
>> >> > Yes, skb will not be classified as inline-able if nr_frags != 1.
>> >> > See is_inline()
>> > 
>> > Maybe I wasn't accurate enough. inline-able skb must have:
>> > 1. skb->len < inline_thold 
>> > 2. nr_frags <= 1
>> > 
>> > Default value for inline_thold is 104 and it is a module parameter
>> > that can be changed.
>> 
>> BTW, the canonical way to deal with minimum length requirements is to
>> use skb_padto().
> 
> I think that in this case it will be a bit of an overshoot. It
> will add many unnecessary operations because it need to make sure that
> there is enough space in the skb linear buffer for the padding. And in
> my case the restriction is on the hardware buffer, so IMHO there is no
> need to manipulate the skb.

If you're copying the packet into a bounce buffer, yes.  But skb_padto()
is the thing to use if you're DMA'ing directly out of the SKB's buffer
memory.
